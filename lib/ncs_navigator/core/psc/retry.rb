# encoding: utf-8

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
      env[request_body_key] = env[:body]
      begin
        attempts += 1
        env[:body] = env[request_body_key] # restore for retry
        app.call(env).tap do
          if should_retry?(env)
            fail TryAgain
          else
            env[request_body_key] = nil
          end
        end
      rescue TryAgain
        retry if attempts < max_attempts
      end
    end

    def should_retry?(env)
      RETRY_STATUSES.include?(env[:status])
    end
    private :should_retry?

    def request_body_key
      @request_body_key ||= [self.class.to_s, 'request_body'].join('.')
    end
    private :request_body_key

    class TryAgain < StandardError; end
  end
end