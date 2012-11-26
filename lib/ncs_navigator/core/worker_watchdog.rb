module NcsNavigator::Core
  ##
  # The worker watchdog consists of four parts:
  #
  # 1. A timer that issues Sidekiq jobs.
  # 2. A Sidekiq job that, when run, updates a Redis key with the current time.
  # 3. Shared configuration.
  # 4. The status check.
  module WorkerWatchdog
    ##
    # The key containing last time a watchdog job completed.
    def worker_watchdog_key
      "nubic:ncs_navigator_core:worker_watchdog_#{Rails.env}:last_checkin"
    end

    ##
    # If the workers haven't checked in within this many seconds, consider
    # them dead.
    def worker_watchdog_threshold
      60
    end

    ##
    # We issue jobs at twice the frequency of the watchdog threshold to avoid
    # spurious edge failures.
    #
    # Consider two jobs issued at times t1 and t2, spaced exactly
    # {#worker_watchdog_threshold} seconds apart.  Each job requires nonzero
    # time to complete.  In a case like this, we will start j2 and expect it to
    # complete at the same time, but j2 requires nonzero time to complete and
    # therefore will not have completed.  This will cause a false negative.
    #
    # To avoid this, we run jobs at twice the threshold frequency.  Assuming
    # each job completes within {#worker_watchdog_threshold} / 4 seconds time
    # (likely, unless Redis is really bogged down), we can be sure that we will
    # always have a valid result in the threshold window iff the workers are
    # alive.
    def watchdog_periodicity
      worker_watchdog_threshold / 2
    end
  end
end
