require 'ncs_navigator/core'

require 'forwardable'

module NcsNavigator::Core::Warehouse
  class LegacyInstrumentImporter
    extend Forwardable

    BLOCK_SIZE = 2500

    def_delegators :@wh_config, :log

    def initialize(wh_config)
      @wh_config = wh_config
      @progress = ProgressTracker.new(wh_config)
    end

    def primary_instrument_tables
      @wh_config.mdes.transmission_tables.select { |t| t.primary_instrument_table? }
    end

    def import
      PaperTrail.whodunnit = 'legacy_instrument_importer'
      begin
        @progress.start

        primary_instrument_tables.each do |table|
          create_or_update_instrument_data_for_primary_model(@wh_config.model table.name)
        end

        @progress.complete
      ensure
        PaperTrail.whodunnit = nil
      end
    end

    def create_or_update_instrument_data_for_primary_model(model)
      count = model.count
      log.info "Updating or creating legacy records for #{count} records from #{model}"
      offset = 0
      while offset < count
        @progress.loading(model)
        LegacyInstrumentDataRecord.transaction do
          model.all(:limit => BLOCK_SIZE, :offset => offset).each do |instance|
            create_or_update_instrument_data_for_primary_record(instance)
          end
        end
        offset += BLOCK_SIZE
      end
    end
    private :create_or_update_instrument_data_for_primary_model

    def create_or_update_instrument_data_for_primary_record(instance)
      core_instrument = Instrument.where(:instrument_id => instance.instrument_id).first

      create_or_update_instrument_data_for_instrument_record(instance, core_instrument)
    end
    private :create_or_update_instrument_data_for_primary_record

    def create_or_update_instrument_data_for_instrument_record(wh_record, core_instrument, parent_record=nil)
      @progress.increment_records

      mdes_table_name = wh_record.class.mdes_table_name
      public_id = wh_record.key.first

      legacy_record = LegacyInstrumentDataRecord.where(
        'mdes_table_name = ? AND public_id = ?', mdes_table_name, public_id).first

      attributes = {
        :mdes_version => @wh_config.mdes.version,
        :instrument => core_instrument,
        :parent_record => parent_record,
        :psu_id => wh_record.try(:psu_id)
      }

      if legacy_record
        log.info("Updating existing legacy record #{legacy_record.id} for #{mdes_table_name}##{public_id}")
        legacy_record.update_attributes(attributes)
      else
        legacy_record = LegacyInstrumentDataRecord.create!(
          attributes.merge(
            :mdes_table_name => wh_record.class.mdes_table_name,
            :public_id => wh_record.key.first
          )
        )
      end

      create_or_update_instrument_values_for_instrument_record(wh_record, legacy_record)

      # find child records
      @wh_config.models_module.mdes_order.collect { |model|
        [model, model.relationships.find { |rel| rel.parent_model == wh_record.class }]
      }.select { |model, rel| rel }.collect { |child_model, rel|
        child_model.all(rel.child_key.first.name => wh_record.key.first)
      }.flatten.each do |child_record|
        create_or_update_instrument_data_for_instrument_record(child_record, core_instrument, legacy_record)
      end
    end
    private :create_or_update_instrument_data_for_instrument_record

    def create_or_update_instrument_values_for_instrument_record(wh_record, legacy_record)
      incoming_names = wh_record.attributes.keys
      existing_names = legacy_record.values.collect(&:mdes_variable_name)

      new_names = (incoming_names - existing_names)
      update_names = (existing_names & incoming_names)
      remove_names = (existing_names - incoming_names)

      new_names.each do |name|
        legacy_record.values.create!(:mdes_variable_name => name, :value => wh_record[name])
        @progress.increment_values
      end

      update_names.each do |name|
        legacy_record.values.detect { |v| v.mdes_variable_name == name }.
          tap { |v| v.value = wh_record[name] }.save!
        @progress.increment_values
      end

      remove_names.each do |name|
        legacy_record.values.detect { |v| v.mdes_variable_name == name }.
          tap { |v| v.value = wh_record[name] }.destroy
      end
    end
    private :create_or_update_instrument_values_for_instrument_record

    # @private
    class ProgressTracker
      extend Forwardable

      def_delegators :@wh_config, :shell

      def initialize(wh_config)
        @wh_config = wh_config
        @instrument_count = 0
        @record_count = 0
        @value_count = 0
        @instr_table_len = wh_config.mdes.transmission_tables.
          select { |t| t.instrument_table? }.collect { |t| t.name.size }.max
      end

      def loading(from_model)
        @current_model = from_model
        show_loading_message
      end

      def start
        @start = Time.now
      end

      def increment_instruments
        @instrument_count += 1
        show_status_message
      end

      def increment_records
        @record_count += 1
        show_status_message
      end

      def increment_values
        @value_count += 1
        show_status_message
      end

      def complete
        shell.clear_line_then_say(
          "Imported or updated %d legacy record%s and %d value%s in %d seconds (%.2f/sec)\n" % [
            @record_count, ('s' if @record_count != 1),
            @value_count, ('s' if @value_count != 1),
            elapsed, response_rate
          ]
        )
      end

      def show_status_message
        shell.clear_line_then_say(
          "<- instrument data from %#{@instr_table_len}s | %d recs / %d values (%.1f/sec)" % [
            @current_model.try(:mdes_table_name),
            @record_count, @value_count, response_rate
          ]
        )
      end

      def show_loading_message
        shell.clear_line_then_say(
          "Importing instruments from %#{@instr_table_len}s | %d recs / %d values [loading]" % [
            @current_model.try(:mdes_table_name),
            @record_count, @value_count, response_rate
          ]
        )
      end

      def response_rate
        @value_count / elapsed
      end

      def elapsed
        (Time.now - @start)
      end
    end
  end
end
