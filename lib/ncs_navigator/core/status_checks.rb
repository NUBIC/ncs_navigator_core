module NcsNavigator::Core
  ##
  # Diagnostics.
  module StatusChecks
    class Report
      attr_accessor :db
      attr_accessor :workers

      def initialize
        self.db = Database.new
        self.workers = BackgroundWorkers.new
      end

      def run
        db.run
        workers.run
      end

      def failed?
        db.failed? || workers.failed?
      end

      def as_json(*)
        {
          'db' => db.failed?,
          'workers' => workers.failed?,
          'failures' => {
            'db' => db.failure,
            'workers' => workers.failure
          }
        }
      end
    end

    module Check
      attr_accessor :failure

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
  end
end
