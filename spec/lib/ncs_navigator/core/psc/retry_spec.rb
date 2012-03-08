require 'spec_helper'

require 'ncs_navigator/core'

module NcsNavigator::Core::Psc
  describe Retry do
    subject { Retry.new(app, 4) }

    let(:app) {
      Class.new do
        attr_accessor :statuses, :last_request_body

        def call(env)
          env[:status] = statuses.shift or fail 'all statuses used'
          self.last_request_body = env[:body]
          env[:body] = "This is the response with #{env[:status]}."
        end
      end.new
    }
    let(:env) { { } }

    it 'retries 3 times by default' do
      Retry.new(app).max_attempts.should == 3
    end

    def expect_status_series(*statuses)
      app.statuses = statuses
      subject.call(env)
      app.statuses.should == []
    end

    [200, 204, 301, 302, 303, 400, 401, 403, 404, 410, 500].each do |status|
      describe "for status #{status}" do
        it 'does not retry' do
          expect_status_series(status)
        end
      end
    end

    [502, 503].each do |status|
      describe "for status #{status}" do
        it 'retries up to the specified number of attempts' do
          expect_status_series(*([status] * 4))
        end

        it 'stops retrying when there is a non-failure response' do
          expect_status_series(status, status, 204)
        end

        it 'retries with the original request body' do
          env[:body] = "Some important info"
          expect_status_series(status, 301)

          app.last_request_body.should == "Some important info"
        end
      end
    end
  end
end
