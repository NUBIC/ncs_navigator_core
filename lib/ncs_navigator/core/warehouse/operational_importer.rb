require 'ncs_navigator/core/warehouse'
# To preload the same version of the models used by OperationalEnumerator
require 'ncs_navigator/core/warehouse/operational_enumerator'

require 'forwardable'
require 'paper_trail'

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

    BLOCK_SIZE = 2500

    attr_reader :wh_config

    def_delegators self, :automatic_producers
    def_delegators :wh_config, :shell, :log

    def initialize(wh_config)
      @wh_config = wh_config
      @core_models_indexed_by_table = {}
      @public_id_indexes = {}
      @failed_associations = []
      @progress = ProgressTracker.new(wh_config)
    end

    def import(*tables)
      PaperTrail.whodunnit = 'operational_importer'
      begin
        @progress.start

        automatic_producers.
          select { |rp| tables.empty? || tables.include?(rp.name) }.
          each do |one_to_one_producer|
            create_simply_mapped_core_records(one_to_one_producer)
          end

        if tables.empty? || tables.any? { |t| [:events, :contact_links, :instruments].include?(t) }
          create_events_and_instruments_and_contact_links
        end

        resolve_failed_associations

        @progress.complete
      ensure
        PaperTrail.whodunnit = nil
      end
    end

    def self.automatic_producers
      OperationalEnumerator.record_producers.reject { |rp|
        %w(LinkContact Event Instrument).include?(rp.model.to_s.demodulize)
      }
    end

    # @private exposed for testing
    def ordered_event_sets
      @ordered_event_sets ||= build_ordered_event_sets
    end

    private

    def create_simply_mapped_core_records(mdes_producer)
      core_model = core_model_for_table(mdes_producer.name)
      mdes_model = mdes_producer.model
      count = mdes_model.count
      offset = 0
      while offset < count
        @progress.loading(mdes_producer.name)
        core_model.transaction do
          mdes_model.all(:limit => BLOCK_SIZE, :offset => offset).each do |mdes_record|
            core_record = apply_mdes_record_to_core(core_model, mdes_record)
            if core_model.respond_to?(:importer_mode)
              core_model.importer_mode { save_core_record(core_record) }
            else
              save_core_record(core_record)
            end
          end
        end
        offset += BLOCK_SIZE
      end
    end

    def create_events_and_instruments_and_contact_links
      build_state_impacting_ids_table

      unless ENV['IMPACT_ONLY']
        create_core_records_without_state_impact(Event)
        create_core_records_without_state_impact(Instrument)
        create_core_records_without_state_impact(ContactLink)
      end

      @progress.loading('events, instruments, and links with p state impact')
      Participant.transaction do
        ordered_event_sets.each do |p_id, events_and_links|
          participant = Participant.where(:p_id => p_id).first

          for_psc = (participant.enroll_status_code == 1)
          Rails.application.redis.sadd(sync_key('participants'), participant.public_id) if for_psc

          events_and_links.each do |event_and_links|
            core_event = apply_mdes_record_to_core(Event, event_and_links[:event])

            if should_affect_participant_state?(core_event)
              participant.set_state_for_event_type(core_event.event_type)
            end

            cache_event_for_psc_sync(participant, core_event) if for_psc

            save_core_record(core_event)
            (event_and_links[:instruments] || []).each do |mdes_i|
              save_core_record(apply_mdes_record_to_core(Instrument, mdes_i))
            end

            (event_and_links[:link_contacts] || []).each do |mdes_lc|
              core_contact_link = apply_mdes_record_to_core(ContactLink, mdes_lc)
              cache_link_contact_for_psc_sync(participant, core_event, core_contact_link) if for_psc
              save_core_record(core_contact_link)
            end
          end
        end
      end
    ensure
      drop_state_impacting_ids_table
    end

    def should_affect_participant_state?(core_event)
      return false unless core_event.new_record?
      # low-high conversion
      if core_event.event_type_code == 32
        low_high_script_model = wh_config.models_module.const_get(:LowHighScript)
        interview = low_high_script_model.first(:event_id => core_event.public_id)
        if interview
          interview.out_visit == '1'
        else
          false
        end
      else
        true
      end
    end

    def sync_key(*key_parts)
      [self.class.name, 'psc_sync', key_parts].flatten.join(':')
    end

    def cache_event_for_psc_sync(participant, core_event)
      return unless core_event.changed?

      Rails.application.redis.tap do |r|
        r.hmset(sync_key('event', core_event.public_id),
          'status', core_event.new_record? ? 'new' : 'changed',
          'event_id', core_event.public_id,
          'start_date', core_event.event_start_date,
          'end_date', core_event.event_end_date,
          'event_type_code', core_event.event_type_code,
          'event_type_label', core_event.event_type.display_text.downcase.strip.gsub(/\s+/, '_'),
          'recruitment_arm', participant.low_intensity? ? 'lo' : 'hi',
          'sort_key', [core_event.event_start_date, '%03d' % core_event.event_type_code].join(':')
        )
        r.sadd(sync_key('p', participant.public_id, 'events'), core_event.public_id)
      end
    end

    def cache_link_contact_for_psc_sync(participant, core_event, core_contact_link)
      instrument_type_code = core_contact_link.instrument.try(:instrument_type_code)

      link_contact_fields = [
        'status', core_contact_link.new_record? ? 'new' : 'changed',
        'contact_link_id', core_contact_link.public_id,
        'event_id', core_event.public_id,
        'contact_id', core_contact_link.contact.public_id,
        'contact_date', core_contact_link.contact.contact_date,
        'sort_key', [
          core_event.public_id,
          core_contact_link.contact.contact_date,
          ('%03d' % instrument_type_code if instrument_type_code)].compact.join(':')
      ]

      if instrument_type_code
        link_contact_fields << 'instrument_id' << core_contact_link.instrument.instrument_id
        link_contact_fields << 'instrument_type' << instrument_type_code
        link_contact_fields << 'instrument_status' <<
          core_contact_link.instrument.instrument_status.display_text.downcase
      end

      collection_key =
        if core_contact_link.instrument_id
          sync_key('p', participant.public_id,
            'link_contacts_with_instrument', core_contact_link.instrument.instrument_id)
        else
          sync_key('p', participant.public_id,
            'link_contacts_without_instrument', core_event.event_id)
        end

      Rails.application.redis.tap do |r|
        r.hmset(sync_key('link_contact', core_contact_link.public_id), *link_contact_fields)
        r.sadd(collection_key, core_contact_link.public_id)
      end
    end

    STATE_IMPACTING_IDS_TABLE_NAME = 'scratch_core_importer_state_impacting_elci'

    def build_state_impacting_ids_table
      ::DataMapper.repository.adapter.tap do |a|
        a.execute("DROP TABLE IF EXISTS #{STATE_IMPACTING_IDS_TABLE_NAME}")
        a.execute(<<-SQL)
          CREATE TABLE #{STATE_IMPACTING_IDS_TABLE_NAME} (
            event_id VARCHAR(36),
            participant_id VARCHAR(36),
            contact_link_id VARCHAR(36),
            instrument_id VARCHAR(36))
        SQL
        a.execute(<<-INSERT)
          INSERT INTO #{STATE_IMPACTING_IDS_TABLE_NAME}
          SELECT e.event_id, e.participant_id, l.contact_link_id, i.instrument_id
          FROM event e
            LEFT JOIN link_contact l ON e.event_id=l.event_id
            LEFT JOIN contact c ON l.contact_id=c.contact_id
            LEFT JOIN instrument i ON e.event_id=i.event_id
          WHERE e.participant_id IS NOT NULL
             AND (
                  (e.event_start_date NOT LIKE '9%' AND e.event_start_date IS NOT NULL)
                  OR
                  (e.event_end_date NOT LIKE '9%' AND e.event_end_date IS NOT NULL)
                  OR
                  (l.contact_link_id IS NOT NULL AND c.contact_date NOT LIKE '9%')
                 )
        INSERT
      end
      @state_impacting_ids_table_built = true
    end

    def drop_state_impacting_ids_table
      ::DataMapper.repository.adapter.tap do |a|
        a.execute("DROP TABLE IF EXISTS #{STATE_IMPACTING_IDS_TABLE_NAME}")
      end
    end

    def build_ordered_event_sets
      build_state_impacting_ids_table unless @state_impacting_ids_table_built
      state_impacting_event_ids_by_participant_id =
        ::DataMapper.repository.adapter.
        select("SELECT * FROM #{STATE_IMPACTING_IDS_TABLE_NAME}").
        inject({}) do |idx, row|
          (idx[row.participant_id] ||= []) << row.event_id; idx
        end

      OrderedEventSets.new(
        @progress,
        state_impacting_event_ids_by_participant_id,
        {
          :event => find_producer(:events).model,
          :link_contact => find_producer(:contact_links).model,
          :instrument => find_producer(:instruments).model
        },
        log
      )
    end

    class OrderedEventSets
      include Enumerable

      attr_reader :log

      def initialize(progress_tracker, event_ids_by_participant_id, models, log)
        @event_ids_by_participant_id = event_ids_by_participant_id
        @mdes_models = models
        @progress = progress_tracker
        @log = log
      end

      def each
        block = []
        p_ids = @event_ids_by_participant_id.keys
        while !p_ids.empty?
          block.concat(@event_ids_by_participant_id[p_ids.shift].uniq)
          if block.size >= block_size || p_ids.empty?
            build_ordered_event_sets_for_events(block).each do |set|
              yield set
            end
            block = []
          end
        end
      end

      def block_size
        @block_size ||= BLOCK_SIZE / 10 # average 7.5 LC's per E
      end

      def build_ordered_event_sets_for_events(event_ids)
        log.debug("Building block of ordered event sets for #{event_ids.size} event id(s)")

        @progress.loading('events, instruments, and links with p state impact')
        events = @mdes_models[:event].all(:event_id => event_ids)
        log.debug("  - #{events.size} event(s)")
        instruments = @mdes_models[:instrument].all(:event_id => event_ids)
        log.debug("  - #{instruments.size} instrument(s)")

        contact_links = @mdes_models[:link_contact].all(:event_id => event_ids)
        log.debug("  - #{contact_links.size} link_contact(s)")
        contacts = @mdes_models[:link_contact].relationships[:contact].
          parent_model.all(:contact_id => contact_links.collect { |cl| cl.contact_id })
        contact_links.each do |cl|
          match = contacts.find { |c| c.contact_id == cl.contact_id }
          cl.contact = match if match
        end

        cl_by_event = contact_links.inject({}) do |idx, cl|
          (idx[cl.event_id] ||= []).tap { |a| a << cl }
          idx
        end

        cl_by_event.values.each { |a|
          a.sort! { |x, y| (x.contact.contact_date || '9') <=> (y.contact.contact_date || '9') }
        }

        in_by_event = instruments.inject({}) do |idx, instr|
          (idx[instr.event_id] ||= []).tap { |a| a << instr }
          idx
        end

        events.inject({}) do |sets, event|
          (sets[event.participant_id] ||= []).tap do |a|
            a << {
              :event => event,
              :link_contacts => cl_by_event[event.event_id],
              :instruments => in_by_event[event.event_id]
            }
          end
          sets
        end.tap { |sets|
          sets.values.each { |a|
            a.sort! { |x, y|
              xcmp, ycmp = [x, y].map { |set|
                e = set[:event]
                cls = (set[:link_contacts] || [])
                dates = [
                  e.event_start_date, e.event_end_date,
                  *cls.collect { |l| l.contact.contact_date }
                ]

                ordinal = Event::TYPE_ORDER.index(e.event_type.to_i) ||
                  fail("No ordinal for event_type #{e.event_type}")
                [
                  # 32 is low-high conversion
                  e.event_type == '32' ? latest_date(*dates) : earliest_date(*dates),
                  ordinal
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

      def latest_date(*dates)
        dates.collect { |d| (d =~ /^9/) ? nil : d }.compact.sort.last
      end
    end

    def create_core_records_without_state_impact(core_model)
      load_message = "#{core_model.name.underscore.gsub('_', ' ').pluralize} without p state impact"
      mdes_model = find_producer(core_model.table_name).model
      key_name = mdes_model.key.first.name
      cond = <<-SQL
        FROM #{mdes_model.mdes_table_name} t
          LEFT JOIN #{STATE_IMPACTING_IDS_TABLE_NAME} i ON t.#{key_name} = i.#{key_name}
        WHERE i.#{key_name} IS NULL
      SQL

      count = ::DataMapper.repository.adapter.select("SELECT COUNT(*) #{cond}").first
      offset = 0

      while offset < count
        @progress.loading(load_message)
        core_model.transaction do
          mdes_model.find_by_sql(
            "SELECT t.* #{cond} ORDER BY #{key_name} LIMIT #{BLOCK_SIZE} OFFSET #{offset}"
          ).each do |mdes_record|
            save_core_record(apply_mdes_record_to_core(core_model, mdes_record))
          end
        end
        offset += BLOCK_SIZE
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
          if associated_public_id && !new_association_id
            @failed_associations << FailedAssociation.new(
              mdes_key, mdes_record.class.mdes_table_name, mdes_variable,
              core_model, core_model_association_id,
              associated_model, associated_public_id)
          end
          core_record.send("#{core_model_association_id}=", new_association_id)
        elsif core_attribute =~ /_code$/
          mdes_value = mdes_record.send(mdes_variable)
          if mdes_value
            code_attribute_name = core_attribute.sub(/_code$/, '').to_sym
            code_attribute = core_model.ncs_coded_attributes[code_attribute_name]
            core_code = ncs_code_object_for(mdes_value, code_attribute.list_name)
            if core_code
              core_record.send("#{code_attribute_name}=", core_code)
            else
              core_record.send("#{core_attribute}=", mdes_value)
            end
          else
            core_record.send("#{core_attribute}=", mdes_record.send(mdes_variable))
          end
        elsif core_attribute =~ /^normalized_.*_disposition$/
          # dispositions are always imported as interim
          disp = mdes_record.send(mdes_variable)
          if disp
            core_record.send("#{core_attribute.sub(/^normalized_/, '')}=", disp.to_i % 500)
          end
        else
          core_record.send("#{core_attribute}=", mdes_record.send(mdes_variable))
        end
      end
      core_record
    end

    def resolve_failed_associations
      Person.transaction do
        @failed_associations.each do |f|
          ident = "#{f.mdes_table_name}[#{f.record_key}]##{f.mdes_variable}"
          assoc_id = public_id_index(f.associated_model)[f.associated_public_id]
          if assoc_id
            log.debug("Late resolving #{ident}.")
            core_record = f.core_model.find(public_id_index(f.core_model)[f.record_key])
            core_record.update_attribute(f.core_model_association_id, assoc_id)
          else
            log.error(
              "MDES association #{ident} refers to a record that is not present in Core.")
          end
        end
      end
    end

    def save_core_record(core_record)
      ident = "#{core_record.class}##{core_record.id}##{core_record.public_id}"
      if core_record.new_record?
        log.debug("Creating #{ident}: #{core_record.inspect}.")
        @progress.increment_creates
      elsif core_record.changed?
        log.debug("Updating #{ident} with #{core_record.changes.inspect}.")
        @progress.increment_updates
      else
        log.debug("#{ident} encountered; no differences.")
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

    def ncs_code_object_for(local_code, list_name)
      ncs_code_list(list_name).detect { |cl| cl.local_code == local_code.to_i }
    end

    def ncs_code_list(list_name)
      ncs_code_lists[list_name] ||= build_ncs_code_list(list_name)
    end

    def build_ncs_code_list(list_name)
      NcsCode.find_all_by_list_name(list_name)
    end

    def ncs_code_lists
      @ncs_code_lists ||= {}
    end

    FailedAssociation = Struct.new(
      :record_key, :mdes_table_name, :mdes_variable,
      :core_model, :core_model_association_id,
      :associated_model, :associated_public_id)

    class ProgressTracker
      extend Forwardable

      def_delegators :@wh_config, :shell, :log

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
        msg = "%d new / %d updated / %d unchanged.\nOperational import complete in %ds (%.1f/s).\n" % [
          @create_count, @update_count, @unchanged_count, elapsed, total_rate
        ]

        shell.clear_line_then_say(msg)
        log.info(msg)
      end

      def total_rate
        (@update_count + @create_count + @unchanged_count) / elapsed
      end

      def elapsed
        Time.now - @start
      end
    end
  end
end
