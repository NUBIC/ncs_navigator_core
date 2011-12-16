require 'ncs_navigator/core/warehouse'
require 'ncs_navigator/core/warehouse/response_set_to_warehouse'
require 'forwardable'

module NcsNavigator::Core::Warehouse
  ##
  # Incrementally builds and yields MDES records for every ResponseSet
  # in the system.
  class InstrumentEnumerator
    extend Forwardable
    include Enumerable

    def self.create_transformer(wh_config)
      NcsNavigator::Warehouse::Transformers::SubprocessTransformer.new(
        wh_config,
        %w(bundle exec rails runner script/instrument_transformer) +
          [wh_config.configuration_file.to_s],
        :directory => File.expand_path('../../../../..', __FILE__)
      )
    end

    def initialize(wh_config)
      @wh_config = wh_config
    end

    def each
      progress = ProgressTracker.new(@wh_config)
      ResponseSet.find_each do |rs|
        progress.increment_response_sets
        progress.increment_responses(rs.responses.size)
        rs.to_mdes_warehouse_records.each do |record|
          progress.increment_records
          yield record
        end
      end
      progress.complete
    end

    # @private
    class ProgressTracker
      extend Forwardable

      def_delegators :@wh_config, :log, :shell

      def initialize(wh_config)
        @wh_config = wh_config
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

      def increment_response_sets
        @response_set_count += 1
        say_progress
      end

      def increment_responses(ct)
        @response_set_count += ct
        say_progress
      end

      def say_progress
        shell.clear_line_then_say(
          "Transforming surveys. %3d set(s), %3d resp => %3d record(s). %.1f/s." % [
            @response_set_count, @response_count, @record_count, rate
          ])
      end

      def complete
        msg = "Transformed %d set(s), %d resp into %d record(s) in %ds (%.1f/s)." % [
          @response_set_count, @response_count, @record_count, elapsed, rate
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
