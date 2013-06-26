# -*- coding: utf-8 -*-


require 'ncs_navigator/core/warehouse'
require 'forwardable'

module NcsNavigator::Core::Warehouse
  ##
  # Incrementally builds and yields MDES records for every Instrument
  # in the system.
  class InstrumentEnumerator
    extend Forwardable
    include Enumerable

    def_delegators :@wh_config, :log, :shell

    def self.create_transformer(wh_config)
      NcsNavigator::Warehouse::Transformers::SubprocessTransformer.new(
        wh_config,
        %w(bundle exec rails runner script/instrument_transformer) +
          [wh_config.configuration_file.to_s],
        :directory => File.expand_path('../../../../..', __FILE__)
      )
    end

    def initialize(wh_config)
      # This is deferred to here so that .create_transformer can be
      # called from the warehouse configuration
      require 'ncs_navigator/core/warehouse/instrument_to_warehouse'
      @wh_config = wh_config
    end

    def each
      progress = ProgressTracker.new(@wh_config, Instrument.count)
      # The small batch size is so that the loaded instrument instances become
      # eligible for GC quickly. (All the records in a batch have strong refs
      # within ActiveRecord's batching infrastructure.)
      # #to_mdes_warehouse_records retains a lot of information within the
      # instrument instance, so having them be GC'd is necessary to keep process
      # memory requirements down. See #3589 for more discussion.
      Instrument.find_each(:batch_size => 5) do |ins|
        progress.increment_instruments

        unless @wh_config.soft_validations || ins.enumerable_to_warehouse?
          log.info "Skipping ResponseSets for Instrument #{ins.instrument_id.inspect} (#{ins.id})."
          next
        end

        progress.increment_response_sets(ins.response_sets.size)
        progress.increment_responses(ins.response_sets.inject(0) { |sum, rs| sum + rs.responses.count })
        log.info "Transforming ResponseSets for Instrument #{ins.instrument_id.inspect} (#{ins.id})"
        begin
          ins.to_mdes_warehouse_records(@wh_config).each do |record|
            progress.increment_records
            yield record
          end
        rescue => e
          yield NcsNavigator::Warehouse::TransformError.for_exception(e,
            "Error enumerating response sets for instrument #{ins.instrument_id.inspect} (#{ins.id}).")
        end
      end
      progress.complete
    end

    # @private
    class ProgressTracker
      extend Forwardable

      def_delegators :@wh_config, :log, :shell

      def initialize(wh_config, ins_total)
        @wh_config = wh_config
        @instrument_total = ins_total
        @instrument_count = 0
        @response_set_count = 0
        @response_count = 0
        @record_count = 0
        @start = Time.now
        log.info "Transforming survey responses into MDES records."
      end

      def increment_records
        @record_count += 1
        say_progress
      end

      def increment_instruments
        @instrument_count += 1
        say_progress
      end

      def increment_response_sets(rs_ct)
        @response_set_count += rs_ct
        say_progress
      end

      def increment_responses(ct)
        @response_count += ct
        say_progress
      end

      def say_progress
        shell.clear_line_then_say(
          "Transforming surveys. %3d/%3d instrument(s), %3d set(s), %3d resp => %3d record(s). %.1f/s." % [
            @instrument_count, @instrument_total, @response_set_count, @response_count, @record_count, rate
          ])
      end

      def complete
        msg = "Transformed %3d instrument(s), %d set(s), %d resp into %d record(s) in %ds (%.1f/s)." % [
          @instrument_count, @response_set_count, @response_count, @record_count, elapsed, rate
        ]
        log.info msg
        shell.clear_line_then_say msg + "\n"
      end

      private

      def rate
        @record_count / elapsed
      end

      def elapsed
        Time.now - @start
      end
    end
  end
end
