# -*- coding: utf-8 -*-

require 'ncs_navigator/core/warehouse'

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

    def_delegators :wh_config, :shell, :log

    def initialize(wh_config, options={})
      @wh_config = wh_config
      @core_models_indexed_by_table = {}
      @public_id_indexes = {}
      @failed_associations = []
      @progress = ProgressTracker.new(wh_config)
      @sync_loader = Psc::SyncLoader.new(OperationalImporterPscSync::KEYGEN)
      @followed_p_ids = options.delete(:followed_p_ids)
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

        if tables.empty? || tables.include?(:ppg_status_histories)
          insert_initial_ppg_status_into_history_if_necessary
        end

        if tables.empty? || tables.include?(:participants)
          set_participant_being_followed
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

    def automatic_producers
      operational_enumerator.record_producers.reject { |rp|
        %w(LinkContact Event Instrument).include?(rp.model_or_reference.to_s.demodulize)
      }
    end

    # @private exposed for testing
    def ordered_event_sets
      @ordered_event_sets ||= build_ordered_event_sets
    end

    private

    def operational_enumerator
      OperationalEnumerator.select_implementation(wh_config)
    end

    def create_simply_mapped_core_records(mdes_producer)
      core_model = core_model_for_table(mdes_producer.name)
      mdes_model = mdes_producer.model(wh_config)
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
      ordered_event_sets.each do |p_id, events_and_links|
        Participant.transaction do
          Participant.importer_mode do
            participant = Participant.where(:p_id => p_id).includes(:participant_consents).first

            for_psc = (participant.being_followed && participant.p_type_code != 6)
            @sync_loader.cache_participant(participant) if for_psc

            # caches
            core_contacts = {}

            events_and_links.each do |event_and_links|
              core_event = apply_mdes_record_to_core(Event, event_and_links[:event])

              participant.set_state_for_imported_event(core_event)

              @sync_loader.cache_event(core_event, participant) if for_psc

              save_core_record(core_event)

              (event_and_links[:instruments] || []).each do |mdes_i|
                core_i = apply_mdes_record_to_core(Instrument, mdes_i)
                save_core_record(core_i)
              end

              (event_and_links[:link_contacts] || []).each do |mdes_lc|
                core_contact_link = apply_mdes_record_to_core(ContactLink, mdes_lc)
                if for_psc
                  contact_id = core_contact_link.contact_id
                  core_contact = (core_contacts[contact_id] ||= Contact.find(contact_id))

                  @sync_loader.cache_contact_link(core_contact_link,
                                                  core_contact,
                                                  core_event,
                                                  participant)
                end
                save_core_record(core_contact_link)
              end
            end
          end
        end
      end
    ensure
      drop_state_impacting_ids_table
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

    def mdes_model_for_core_table(core_table)
      find_producer(core_table).model(wh_config)
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
          :event => mdes_model_for_core_table(:events),
          :link_contact => mdes_model_for_core_table(:contact_links),
          :instrument => mdes_model_for_core_table(:instruments)
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
                  earliest_date(*dates),
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
      mdes_model = find_producer(core_model.table_name).model(wh_config)
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

    def insert_initial_ppg_status_into_history_if_necessary
      @progress.loading('PPG Details not present in PPG Status History')
      ppg_details_model = mdes_model_for_core_table(:ppg_details)
      ppg_details_requiring_correction = ppg_details_model.find_by_sql(<<-SQL)
        SELECT d.* FROM ppg_details d
        WHERE d.ppg_first <> (
          SELECT ppg_status FROM ppg_status_history h
          WHERE h.p_id=d.p_id ORDER BY h.ppg_status_date LIMIT 1
        ) OR NOT EXISTS (
          SELECT 'x' FROM ppg_status_history h WHERE h.p_id=d.p_id
        )
      SQL

      ppg_details_requiring_correction.each do |ppg_details|
        query = <<-SQL
          SELECT contact_date, contact_type
          FROM contact
            INNER JOIN link_contact USING (contact_id)
            INNER JOIN event USING (event_id)
          WHERE event_type = '29' AND participant_id='#{ppg_details.p_id}'
          ORDER BY contact_date DESC
          LIMIT 1
        SQL
        result = ::DataMapper.repository.adapter.select(query).first

        if result
          PpgStatusHistory.create(
            :participant_id => Participant.find_by_p_id(ppg_details.p_id).id,
            :ppg_status_code => ppg_details.ppg_first,
            :ppg_status_date => result.contact_date,
            :ppg_info_source_code => 1,
            :ppg_info_mode_code => result.contact_type,
            :ppg_comment => 'Missing history entry inferred from ppg_details.ppg_first during import into NCS Navigator.'
          )
          @progress.increment_creates
        else
          log.warn("Participant #{ppg_details.p_id} is missing an initial status history record. The necessary information to infer the initial status history record is also not present.")
        end
      end
    end

    def set_participant_being_followed
      if @followed_p_ids
        Participant.update_all(['being_followed = ?', false],
                               ['p_id NOT IN (?)', @followed_p_ids])
      else
        set_participant_being_followed_using_heuristic
      end
    end

    def set_participant_being_followed_using_heuristic
      ActiveRecord::Base.connection.
        execute(<<-SQL)
          UPDATE participants p
          SET being_followed=(
            enroll_status_code=1
            AND (
              ( -- ever pregnant
                EXISTS (SELECT 'x' FROM ppg_details d WHERE d.participant_id=p.id AND d.ppg_first_code=1)
                OR
                EXISTS (SELECT 'x' FROM ppg_status_histories h WHERE h.participant_id=p.id AND h.ppg_status_code=1)
              ) OR ( -- a child
                p.p_type_code = 6
              )
            )
          )
        SQL
    end

    def find_producer(name)
      operational_enumerator.record_producers.find { |rp| rp.name.to_sym == name.to_sym }
    end

    def column_map(core_model)
      column_maps[core_model] ||=
        find_producer(core_model.table_name).column_map(core_model.attribute_names, wh_config)
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
          apply_ncs_coded_attribute(core_model, mdes_record, core_record, core_attribute, mdes_variable)
        elsif core_attribute =~ /^normalized_.*_disposition$/
          # dispositions are always imported as interim
          disp = mdes_record.send(mdes_variable)
          if disp
            core_record.send("#{core_attribute.sub(/^normalized_/, '')}=", disp.to_i % 500)
          end
        elsif core_attribute =~ /^mdes_datetime_value_.*$/
          core_record.send("#{core_attribute.sub(/^mdes_datetime_value_/, '')}=", mdes_record.send(mdes_variable))
        elsif core_attribute =~ /^non_null_.*_date$/
          core_record.send("#{core_attribute.sub(/^non_null_/, '')}=", mdes_record.send(mdes_variable))
        elsif core_attribute == "computed_age"
          core_record.send("age=", mdes_record.send(mdes_variable))
        elsif core_attribute == "computed_age_range"
          apply_ncs_coded_attribute(core_model, mdes_record, core_record, "age_range_code", mdes_variable)
        else
          core_record.send("#{core_attribute}=", mdes_record.send(mdes_variable))
        end
      end
      core_record
    end

    def apply_ncs_coded_attribute(core_model, mdes_record, core_record, core_attribute, mdes_variable)
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
        if core_record.has_attribute?("imported_invalid")
          core_record.imported_invalid = true unless core_record.valid?
        end
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

        @rails_log_last_unit = nil
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
        msg = "%3d new / %3d updated / %3d unchanged. Importing %s. %.1f/s" % [
          @create_count, @update_count, @unchanged_count, @unit_name, total_rate
        ]

        shell.clear_line_then_say(msg)
        rails_info(msg, log_progress_to_rails_log?)
      end

      def say_loading_message
        msg = "%3d new / %3d updated / %3d unchanged. Importing %s. [loading]" % [
          @create_count, @update_count, @unchanged_count, @unit_name
        ]

        shell.clear_line_then_say(msg)
        rails_info(msg, true)
      end

      def complete
        msg = "%d new / %d updated / %d unchanged.\nOperational import complete in %ds (%.1f/s).\n" % [
          @create_count, @update_count, @unchanged_count, elapsed, total_rate
        ]

        shell.clear_line_then_say(msg)
        log.info(msg)
      end

      def total_count
        @update_count + @create_count + @unchanged_count
      end

      def total_rate
        total_count / elapsed
      end

      def elapsed
        Time.now - @start
      end

      def log_progress_to_rails_log?
        (@unit_name != @rails_log_last_unit) || ((total_count % 250) == 0)
      end

      def rails_info(msg, definitely_log)
        if definitely_log
          Rails.logger.info(msg)
          @rails_log_last_unit = @unit_name
        end
      end
    end
  end
end
