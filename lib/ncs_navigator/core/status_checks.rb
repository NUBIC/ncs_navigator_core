module NcsNavigator::Core
  ##
  # Diagnostics.
  module StatusChecks
    module Check
      attr_accessor :failure

      def ok?
        !failed?
      end

      def failed?
        !!failure
      end

      def log_failure(failure)
        self.failure = "#{self.class.name} check failed: #{failure}"
      end
    end

    class Database
      include Check

      def run
        begin
          result = run_test_query

          log_failure("#{test_query} returned nil") if result.nil?
        rescue Exception => e
          log_failure("#{e.class} (#{e.message})")
        end
      end

      def run_test_query
        ActiveRecord::Base.connection.execute(test_query)
      end

      def test_query
        "SELECT 1"
      end
    end

    class BackgroundWorkers
      include Check
      include NcsNavigator::Core::WorkerWatchdog

      def run
        redis = Rails.application.redis

        begin
          unless redis.exists(worker_watchdog_key)
            log_failure('workers have never checked in')
            return
          end

          last_checkin = Time.at(redis.get(worker_watchdog_key).to_i)
          ok_threshold = Time.now - worker_watchdog_threshold

          if last_checkin < ok_threshold
            log_failure("workers last checked in at #{last_checkin}, which is more than #{worker_watchdog_threshold} seconds ago")
          end
        rescue Exception => e
          log_failure("#{e.class} (#{e.message})")
        end
      end
    end

    class EventTypeOrder
      include Check

      def run
        begin
          log_failure('type order is different') if ::EventTypeOrder.different?
        rescue Exception => e
          log_failure("#{e.class} (#{e.message})")
        end
      end
    end

    class Report
      CHECKS = {
        'db'                => Database,
        'event_type_order'  => EventTypeOrder,
        'workers'           => BackgroundWorkers
      }

      CHECKS.keys.each { |c| attr_accessor c }
      
      def initialize
        CHECKS.each { |k, v| send("#{k}=", v.new) }
      end

      def run
        CHECKS.keys.each { |k| send(k).run }
      end

      def failed?
        CHECKS.keys.any? { |k| send(k).failed? }
      end

      def as_json(*)
        {
          'db' => db.ok?,
          'event_type_order' => event_type_order.ok?,
          'workers' => workers.ok?,
          'failures' => {
            'db' => db.failure,
            'event_type_order' => event_type_order.failure,
            'workers' => workers.failure
          }
        }
      end
    end
  end
end
