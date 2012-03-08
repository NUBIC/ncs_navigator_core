require 'ncs_navigator/core'

module NcsNavigator::Core::Psc
  class Retry
    RETRY_STATUSES = [502, 503]

    attr_reader :max_attempts, :app

    def initialize(app, max_attempts=3)
      @app = app
      @max_attempts = max_attempts
    end

    def call(env)
      attempts = 0
      request_body = env[:body]
      begin
        attempts += 1
        env[:body] = request_body # restore for retry
        app.call(env).tap do
          fail TryAgain if should_retry?(env)
        end
      rescue TryAgain
        retry if attempts < max_attempts
      end
    end

    def should_retry?(env)
      RETRY_STATUSES.include?(env[:status])
    end
    private :should_retry?

    class TryAgain < StandardError; end
  end
end
