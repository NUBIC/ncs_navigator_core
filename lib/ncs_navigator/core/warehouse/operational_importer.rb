require 'ncs_navigator/core/warehouse'
# To preload the same version of the models used by OperationalEnumerator
require 'ncs_navigator/core/warehouse/operational_enumerator'

require 'forwardable'

module NcsNavigator::Core::Warehouse
  ##
  # A utility that takes the entire contents of an MDES Warehouse
  # instance and initializes or updates this Core deployment's
  # operational tables to match its contents.
  #
  # The mappings from the MDES Warehouse to Core tables are defined in
  # {OperationalEnumerator}.
  class OperationalImporter
    extend Forwardable

    attr_reader :wh_config

    def_delegators self, :automatic_producers
    def_delegators :wh_config, :shell, :log

    def initialize(wh_config)
      @wh_config = wh_config
      @core_models_indexed_by_table = {}
      @public_id_indexes = {}
      @progress = ProgressTracker.new(wh_config)
      NcsNavigator::Warehouse::DatabaseInitializer.new(wh_config).set_up_repository
    end

    def import(*tables)
      @progress.start
      automatic_producers.
        select { |rp| tables.empty? || tables.include?(rp.name) }.
        each do |one_to_one_producer|
          create_simply_mapped_core_records(one_to_one_producer)
        end
      if tables.empty? || tables.include?(:events) || tables.include?(:contact_links)
        create_events_and_contact_links
      end
      @progress.complete
    end

    def self.automatic_producers
      OperationalEnumerator.record_producers.reject { |rp|
        %w(LinkContact Event).include?(rp.model.to_s.demodulize)
      }
    end

    # @private exposed for testing
    def ordered_event_sets
      @ordered_event_sets ||= build_ordered_event_sets
    end

    private

    def create_simply_mapped_core_records(mdes_producer)
      core_model = core_model_for_table(mdes_producer.name)
      @progress.loading(mdes_producer.name)
      mdes_producer.model.all.each do |mdes_record|
        core_record = apply_mdes_record_to_core(core_model, mdes_record)
        save_core_record(core_record)
      end
    end

    def create_events_and_contact_links
      @progress.loading('events with no p state impact')
      create_core_records_by_mdes_public_ids(Event,
        no_state_impact_event_and_link_contact_ids.collect { |row| row.event_id })
      @progress.loading('contact links with no p state impact')
      create_core_records_by_mdes_public_ids(ContactLink,
        no_state_impact_event_and_link_contact_ids.collect { |row| row.contact_link_id }.compact)
      @progress.loading('events and contact links with p state impact')
      ordered_event_sets.each do |p_id, events_and_links|
        participant = Participant.find_by_p_id(p_id)
        events_and_links.each do |mdes_event, *mdes_link_contacts|
          core_event = apply_mdes_record_to_core(Event, mdes_event)
          if core_event.new_record?
            participant.set_state_for_event_type(core_event.event_type)
          end
          save_core_record(core_event)
          mdes_link_contacts.compact.each do |mdes_lc|
            save_core_record(apply_mdes_record_to_core(ContactLink, mdes_lc))
          end
        end
      end
    end

    def no_state_impact_event_and_link_contact_ids
      @no_state_impact_event_and_link_contact_ids ||= ::DataMapper.repository.adapter.select(
        %{
          SELECT e.event_id, l.contact_link_id
          FROM event e
            LEFT JOIN link_contact l ON e.event_id=l.event_id
            LEFT JOIN contact c ON l.contact_id=c.contact_id
          WHERE e.participant_id IS NULL
             OR (
                  (e.event_start_date LIKE '9%' OR e.event_start_date IS NULL)
                  AND
                  (e.event_end_date LIKE '9%' OR e.event_end_date IS NULL)
                  AND
                  (l.contact_link_id IS NULL OR c.contact_date LIKE '9%')
                )
        }
      )
    end

    def build_ordered_event_sets
      event_ids = no_state_impact_event_and_link_contact_ids.collect { |row| row.event_id }
      events = find_producer(:events).model.all(:event_id.not => event_ids)
      contact_links = find_producer(:contact_links).model.all(:event_id.not => event_ids)

      cl_by_event = contact_links.inject({}) do |idx, cl|
        (idx[cl.event_id] ||= []).tap { |a| a << cl }
        idx
      end

      cl_by_event.values.each { |a|
        a.sort! { |x, y| (x.contact.contact_date || '9') <=> (y.contact.contact_date || '9') }
      }

      events.inject({}) do |sets, event|
        (sets[event.participant_id] ||= []).tap do |a|
          a << [event, *cl_by_event[event.event_id]]
        end
        sets
      end.tap { |sets|
        sets.values.each { |a|
          a.sort! { |x, y|
            xe, *xcl = x
            ye, *ycl = y
            xcmp, ycmp = [[xe, xcl], [ye, ycl]].collect { |e, cls|
              [
                earliest_date(
                  e.event_start_date, e.event_end_date,
                  *cls.collect { |l| l.contact.contact_date }),
                Event::TYPE_ORDER.index(e.event_type.to_i)
              ]
            }
            xcmp <=> ycmp
          }
        }
      }
    end

    def earliest_date(*dates)
      dates.collect { |d| (d =~ /^9/) ? nil : d }.compact.sort.first
    end

    def create_core_records_by_mdes_public_ids(core_model, id_list)
      mdes_model = find_producer(core_model.table_name).model
      mdes_model.all(mdes_model.key.first.name => id_list).each do |mdes_record|
        save_core_record(apply_mdes_record_to_core(core_model, mdes_record))
      end
    end

    def find_producer(name)
      OperationalEnumerator.record_producers.find { |rp| rp.name.to_sym == name.to_sym }
    end

    def column_map(core_model)
      column_maps[core_model] ||=
        find_producer(core_model.table_name).column_map(core_model.attribute_names)
    end

    def column_maps
      @column_maps ||= {}
    end

    # @return a core record corresponding to the MDES record. It may
    #   or may not be a record that already exists in core. Whether or
    #   not it is, it will have been sync'd with the input MDES record
    #   but not saved.
    def apply_mdes_record_to_core(core_model, mdes_record)
      mdes_key = mdes_record.key.first
      core_record =
        if existing_id = public_id_index(core_model)[mdes_key]
          core_model.find(existing_id)
        else
          core_model.new
        end
      column_map(core_model).each do |core_attribute, mdes_variable|
        if core_attribute =~ /^public_id_for_/
          # This is the format generated in DatabaseEnumeratorHelpers for
          # joined public ID columns
          associated_table, core_model_association_id =
            (core_attribute.scan /^public_id_for_(.*)_as_(.*)$/).first

          associated_model = core_model_for_table(associated_table)
          associated_public_id = mdes_record.send(mdes_variable)

          new_association_id = public_id_index(associated_model)[associated_public_id]
          unless new_association_id
            log.error(
              "MDES association #{mdes_record.class.mdes_table_name}[#{mdes_record.key.first}]##{mdes_variable} refers to a record that is not present in Core.")
          end
          core_record.send("#{core_model_association_id}=", new_association_id)
        else
          core_record.send("#{core_attribute}=", mdes_record.send(mdes_variable))
        end
      end
      core_record
    end

    def save_core_record(core_record)
      if core_record.new_record?
        @progress.increment_creates
      elsif core_record.changed?
        @progress.increment_updates
      else
        @progress.increment_unchanged
      end
      core_record.save!
      public_id_index(core_record.class)[core_record.public_id] = core_record.id
    end

    def core_model_for_table(name)
      name = name.to_s
      @core_models_indexed_by_table[name] ||= Object.const_get(name.singularize.camelize)
    end

    ##
    # @return [Hash<String, Fixnum>] a mapping from public IDs to
    #   internal IDs for the given model.
    def public_id_index(core_model)
      @public_id_indexes[core_model.table_name] ||= build_public_id_index(core_model)
    end

    def build_public_id_index(core_model)
      index_query =
        "SELECT id, #{core_model.public_id_field} AS public_id FROM #{core_model.table_name}"
      ActiveRecord::Base.connection.
        select_all(index_query).
        inject({}) do |idx, row|
        idx[row['public_id']] = row['id']
        idx
      end
    end

    class ProgressTracker
      extend Forwardable

      def_delegators :@wh_config, :shell

      def initialize(wh_config)
        @wh_config = wh_config
        @update_count = 0
        @create_count = 0
        @unchanged_count = 0
      end

      def start
        @start = Time.now
      end

      def loading(name)
        @unit_name = name
        say_loading_message
      end

      def increment_updates
        @update_count += 1
        say_progress_message
      end

      def increment_creates
        @create_count += 1
        say_progress_message
      end

      def increment_unchanged
        @unchanged_count += 1
        say_progress_message
      end

      def say_progress_message
        shell.clear_line_then_say(
          "%3d new / %3d updated / %3d unchanged. Importing %s. %.1f/s" % [
            @create_count, @update_count, @unchanged_count, @unit_name, total_rate
          ]
        )
      end

      def say_loading_message
        shell.clear_line_then_say(
          "%3d new / %3d updated / %3d unchanged. Importing %s. [loading]" % [
            @create_count, @update_count, @unchanged_count, @unit_name
          ]
        )
      end

      def complete
        shell.clear_line_then_say(
          "%3d new / %3d updated / %3d unchanged. %.1f/s. Operational import complete.\n" % [
            @create_count, @update_count, @unchanged_count, total_rate
          ]
        )
      end

      def total_rate
        (@update_count + @create_count + @unchanged_count) / (Time.now - @start)
      end
    end
  end
end
