require 'spec_helper'

module NcsNavigator::Core::StatusChecks
  shared_examples_for 'a status check' do
    describe '#failed?' do
      it 'returns true if failure is non-empty' do
        check.failure = 'oops'

        check.should be_failed
      end

      it 'returns false if failure is empty' do
        check.failure = nil

        check.should_not be_failed
      end
    end

    describe '#ok?' do
      it 'returns !failed?' do
        check.failure = nil

        check.should be_ok
      end
    end
  end

  describe Report do
    let(:report) { Report.new }

    describe '#to_json' do
      let(:fn) { Rails.root.join('vendor/ncs_navigator_schema/system_status_schema.json') }

      it 'satisfies the system-status schema' do
        v = NcsNavigator::Core::Field::JSONValidator.new(fn)

        v.validate(report.to_json).should_not have_errors
      end
    end
  end

  # These examples are a bit split from reality, but setting up real database
  # error conditions is something of a mess.  You have to:
  #
  # 1. run these tests outside of a transaction
  # 2. kill the database or otherwise make it inaccessible
  # 3. be sure to start it up after the test
  #
  # The most direct way to do (2) and (3) is via KILL, but that fails pretty
  # quickly when one considers things like permissions and databases on other
  # machines.  So now we get into ideas like altering the ActiveRecord database
  # connection pool to point somewhere invalid, which is squarely in the middle
  # of Not Worth The Effort.
  describe Database do
    let(:check) { Database.new }

    it_should_behave_like 'a status check'

    it 'fails if the test query raises an exception' do
      check.should_receive(:run_test_query).and_raise(Exception.new('boom'))

      check.run

      check.failure.should =~ /Database check failed: Exception \(boom\)/
    end

    it 'fails if the test query returns nil' do
      check.stub!(:run_test_query => nil)

      check.run

      check.failure.should =~ /Database check failed: #{check.test_query} returned nil/
    end
  end

  describe 'background worker check' do
    let(:check) { BackgroundWorkers.new }
    let(:now) { Time.parse('2000-01-01T00:00:00Z') }
    let(:redis) { Rails.application.redis }

    include NcsNavigator::Core::WorkerWatchdog

    it_should_behave_like 'a status check'

    it 'fails if the workers have never checked in' do
      redis.flushdb

      check.run

      check.failure.should include("BackgroundWorkers check failed: workers have never checked in")
    end

    it "fails if the workers haven't checked in within the watchdog threshold" do
      Time.stub!(:now => now)
      last_checkin = (now - worker_watchdog_threshold * 2).to_i
      redis.set(worker_watchdog_key, last_checkin)

      check.run

      check.failure.should include("BackgroundWorkers check failed: workers last checked in at #{Time.at(last_checkin)}, which is more than #{worker_watchdog_threshold} seconds ago")
    end

    it 'fails if the Redis client throws an exception' do
      Rails.application.redis.should_receive(:get).and_raise(Exception.new('boom'))

      check.run

      check.failure.should include("BackgroundWorkers check failed: Exception (boom)")
    end
  end

  describe 'event type order check' do
    let(:check) { EventTypeOrder.new }

    it_should_behave_like 'a status check'

    after do
      ::EventTypeOrder.persist_if_different
    end

    it 'fails if the event type order does not match Event::TYPE_ORDER' do
      ::EventTypeOrder.delete_all

      check.run

      check.failure.should include("EventTypeOrder check failed: type order is different")
    end
  end
end
