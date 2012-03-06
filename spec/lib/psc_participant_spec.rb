require 'spec_helper'
require 'webmock/rspec'

describe PscParticipant do
  let(:person_id) { 'this_one_person' }
  let(:person) { Factory(:person, :person_id => person_id) }
  let(:p_id) { 'this_one_participant' }
  let(:participant) { Factory(:participant, :p_id => p_id).tap { |p| p.person = person } }

  let(:user) { mock(:username => 'alice', :cas_proxy_ticket => 'PT-alice-1') }
  let(:psc) { PatientStudyCalendar.new(user) }

  let(:sa_levels) { PscParticipant::ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS }

  subject { PscParticipant.new(psc, participant) }

  before do
    WebMock.disable_net_connect!
  end

  def psc_url(*parts)
    [
      NcsNavigator.configuration.psc_uri.to_s.sub(%r{/$}, ''),
      'api', 'v1',
      parts
    ].flatten.join('/')
  end

  let(:registration_path) { psc_url('studies', 'NCS%20Hi-Lo', 'schedules', person_id) }

  def stub_registration_check(response=nil)
    stub_request(:get, registration_path).
      to_return(response ? response : { :status => 200 }).times(1).then.
      to_raise("should only be invoked once")
  end

  describe '#registered?' do
    describe 'when registered' do
      before do
        @check = stub_registration_check
      end

      it 'returns true' do
        subject.should be_registered
        @check.should have_been_requested
      end

      it 'caches the result' do
        subject.registered?
        subject.should be_registered
      end
    end

    describe 'when not registered' do
      before do
        @check = stub_registration_check(:status => 404)
      end

      it 'returns false' do
        subject.should_not be_registered
      end

      it 'caches the result' do
        subject.registered?
        subject.should_not be_registered
      end
    end

    describe 'when there is an unexpected response status' do
      [400, 403, 500].each do |s|
        it "fails with #{s}" do
          stub_registration_check(:status => s, :body => 'No frob allowed')

          lambda { subject.registered? }.
            should raise_error(PatientStudyCalendar::ResponseError, 'No frob allowed')
        end
      end
    end
  end

  ##
  # @returns a proc which takes a webmock request and returns true or
  #   false as the XML in the body has the given value at the given path
  def psc_xml_matching(xpath, value)
    proc do |req|
      actual = Nokogiri::XML(req.body).xpath(xpath, Psc.xml_namespace)
      actual.first.to_s == value
    end
  end

  describe '#register!' do
    let(:assignments_path) {
      psc_url('studies', 'NCS%20Hi-Lo', 'sites', 'GCSC', 'subject-assignments')
    }

    describe 'when already registered' do
      before do
        stub_registration_check
      end

      it 'does nothing' do
        subject.register!('2010-01-02', 'dc')
        # expect no webmock failures
      end
    end

    describe 'when not yet registered' do
      before do
        stub_registration_check(:status => 404)
      end

      context do
        before do
          stub_request(:post, assignments_path).to_return(:status => 201)
          subject.valid.keys.each { |k| subject.valid[k] = true }
          subject.register!('2011-03-07', 'dc')
        end

        it 'registers using the provided date' do
          WebMock.should have_requested(:post, assignments_path).
            with(&psc_xml_matching('/psc:registration/@date', '2011-03-07'))
        end

        it 'registers using the provided segment ID' do
          WebMock.should have_requested(:post, assignments_path).
            with(&psc_xml_matching('/psc:registration/@first-study-segment-id', 'dc'))
        end

        it 'registers using the person_id as the desired assignment id' do
          WebMock.should have_requested(:post, assignments_path).
            with(&psc_xml_matching('/psc:registration/@desired-assignment-id', person_id))
        end

        it 'registers using the current user as the manager' do
          WebMock.should have_requested(:post, assignments_path).
            with(&psc_xml_matching('/psc:registration/@subject-coordinator-name', 'alice'))
        end

        {
          :first_name => 'first-name',
          :last_name => 'last-name',
          :person_id => 'person-id'
        }.each do |person_attr, xml_attr|
          it "uses #{person_attr} from the person for the registering subject's #{xml_attr}" do
            WebMock.should have_requested(:post, assignments_path).with(&psc_xml_matching(
                "/psc:registration/psc:subject/@#{xml_attr}", person.send(person_attr)))
          end
        end

        it "uses 'not reported' for the registering subject's gender" do
          WebMock.should have_requested(:post, assignments_path).with(&psc_xml_matching(
              "/psc:registration/psc:subject/@gender", 'not reported'))
        end

        it 'caches the fact the the participant is registered when successful' do
          subject.register!('2010-04-05', 'Pregnancy Screener')
          subject.should be_registered
        end

        it 'invalidates the schedule cache' do
          subject.valid.values.uniq.should == [false]
        end
      end

      describe 'and there is an unexpected response status' do
        [400, 404, 403, 500].each do |s|
          it "fails with #{s}" do
            stub_request(:post, assignments_path).
              to_return(:status => s, :body => 'No frob allowed')

            lambda { subject.register!('2011-05-03', 'dc') }.
              should raise_error(PatientStudyCalendar::ResponseError, 'No frob allowed')
          end
        end
      end
    end
  end

  describe '#append_study_segment' do
    describe 'when not registered' do
      before do
        stub_registration_check(:status => 404)
      end

      it 'does nothing' do
        subject.append_study_segment('2011-06-09', 'dc')
        # expect no WebMock error
      end
    end

    context do
      before do
        # for cache tests
        subject.valid.keys.each { |k| subject.valid[k] = true }

        stub_registration_check
        stub_request(:post, registration_path).to_return(:status => 201)
        subject.append_study_segment('2014-05-02', 'some-id')
      end

      it 'uses the provided date' do
        WebMock.should have_requested(:post, registration_path).
          with(&psc_xml_matching('/psc:next-scheduled-study-segment/@start-date', '2014-05-02'))
      end

      it 'uses the provided segment ID' do
        WebMock.should have_requested(:post, registration_path).
          with(&psc_xml_matching('/psc:next-scheduled-study-segment/@study-segment-id', 'some-id'))
      end

      it 'always appends per protocol' do
        WebMock.should have_requested(:post, registration_path).
          with(&psc_xml_matching('/psc:next-scheduled-study-segment/@mode', 'per-protocol'))
      end

      it 'invalidates the :sa_list cache level' do
        subject.valid[:sa_list].should be_false
      end

      it 'invalidates the :sa_content cache level' do
        subject.valid[:sa_content].should be_false
      end
    end

    describe 'and there is an unexpected response status' do
      before do
        stub_registration_check
      end

      [400, 403, 404, 500].each do |s|
        it "fails with #{s}" do
          stub_request(:post, registration_path).
            to_return(:status => s, :body => 'No frob allowed')

          lambda { subject.append_study_segment('2011-05-03', 'dc') }.
            should raise_error(PatientStudyCalendar::ResponseError, 'No frob allowed')
        end
      end
    end
  end

  describe '#schedule' do
    let(:schedules_path) { psc_url('subjects', person_id, 'schedules.json') }

    describe 'when not cached' do
      before do
        stub_request(:get, schedules_path).to_return(
          :status => 200,
          :body => '{"days": {"2001-01-01": []}}',
          :headers => { :content_type => 'application/json' }
        ).times(1).to_raise("should only be called once")
        @result = subject.schedule
      end

      it 'returns the schedule hash' do
        @result['days'].keys.should == %w(2001-01-01)
      end

      it 'requests the schedule' do
        WebMock.should have_requested(:get, schedules_path)
      end

      PscParticipant::ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS.each do |cache_level|
        it "marks #{cache_level.inspect} as valid" do
          subject.valid[cache_level].should be_true
        end
      end

      it 'caches the schedule' do
        # second time
        lambda { subject.schedule }.should_not raise_error
      end
    end

    describe 'when cached' do
      before do
        sa_levels.each { |k| subject.valid[k] = false }
        subject.schedule = { 'days' => { '2011-01-01' => [] } }
        stub_request(:get, schedules_path).to_return(
          :status => 200,
          :body => '{"days": {"2011-01-02": []}}',
          :headers => { :content_type => 'application/json' }
        )
      end

      PscParticipant::ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS.each do |cache_level|
        describe "for #{cache_level.inspect}" do
          let(:other_cache_level) { (sa_levels - [cache_level]).first }

          describe 'when the cache is valid' do
            before do
              subject.valid[cache_level] = true
              @result = subject.schedule(cache_level)
            end

            it 'returns the cached value' do
              @result['days'].keys.should == %w(2011-01-01)
            end

            it 'does not change other cache validity' do
              subject.valid[other_cache_level].should be_false
            end
          end

          describe 'when the cache is invalid' do
            before do
              subject.valid[cache_level] = false
              @result = subject.schedule(cache_level)
            end

            it 'renews the schedule' do
              @result['days'].keys.should == %w(2011-01-02)
            end

            it 'marks all caches as valid' do
              sa_levels.each { |k| subject.valid[k].should be_true }
            end
          end
        end
      end
    end

    describe 'when there is no such schedule' do
      before do
        stub_request(:get, schedules_path).
          to_return(:status => 404, :body => 'No such')
      end

      it 'returns empty' do
        subject.schedule.should == {}
      end
    end

    describe 'when there is an unexpected response status' do
      [400, 403, 500].each do |s|
        it "fails with #{s}" do
          stub_request(:get, schedules_path).
            to_return(:status => s, :body => 'No frob allowed')

          lambda { subject.schedule }.
            should raise_error(PatientStudyCalendar::ResponseError, 'No frob allowed')
        end
      end
    end
  end

  describe '#scheduled_activities' do
    before do
      subject.schedule = {
        'days' => {
          '2010-03-05' => {
            'activities' => [
              { 'id' => '351', 'activity' => { 'name' => 'Foo' } },
              { 'id' => '352', 'activity' => { 'name' => 'Bar' } }
            ]
          },
          '2010-06-03' => {
            'activities' => [
              { 'id' => '631', 'activity' => { 'name' => 'Baz' } }
            ]
          }
        }
      }
      sa_levels.each { |l| subject.valid[l] = true }
    end

    it 'indexes all the activities by ID' do
      subject.scheduled_activities.keys.sort.should == %w(351 352 631)
    end

    it 'can retrieve an arbitrary activity' do
      subject.scheduled_activities['352']['activity']['name'].should == 'Bar'
    end

    it 'is empty if the schedule is empty' do
      subject.schedule = {}
      subject.scheduled_activities.should be_empty
    end
  end

  describe '#scheduled_events' do
    def schedule_day(date, sas)
      {
        'activities' => sas.collect { |sa| sa.tap { |x|
            x['current_state'] ||= {}
            x['current_state']['date'] = date
            x['ideal_date'] ||= date
          }
        }
      }
    end

    before do
      sa_levels.each { |l| subject.valid[l] = true }
      subject.schedule = {
        'days' => {
          '2010-01-04' => schedule_day('2010-01-04', [
              { 'id' => '0104a', 'labels' => 'event:pv1 instrument:foo' },
              { 'id' => '0104b' },
              { 'id' => '0104c', 'labels' => 'event:informed_consent' }
            ]),
          '2010-01-05' => schedule_day('2010-01-05', [
              { 'id' => '0105a', 'labels' => 'event:pv1', 'ideal_date' => '2010-01-04' }
            ]),
          '2010-07-02' => schedule_day('2010-07-02', [
              { 'id' => '0702a', 'labels' => 'event:pv2' },
              { 'id' => '0702b', 'labels' => 'event:informed_consent' }
           ])
        }
      }
    end

    it 'includes an event for every event type represented' do
      subject.scheduled_events.collect { |se| se[:event_type_label] }.uniq.sort.should ==
        %w(informed_consent pv1 pv2)
    end

    it 'includes an event for every start date represented' do
      subject.scheduled_events.collect { |se| se[:start_date] }.uniq.sort.should ==
        %w(2010-01-04 2010-07-02)
    end

    it 'considers event types with different ideal dates to be separate' do
      subject.scheduled_events.
        select { |se| se[:event_type_label] == 'informed_consent' }.
        collect { |se| se[:start_date] }.sort.should == %w(2010-01-04 2010-07-02)
    end

    it 'groups by the ideal date, not the current date' do
      subject.scheduled_events.
        find { |se| se[:event_type_label] == 'pv1' }[:scheduled_activities].
        sort.should == %w(0104a 0105a)
    end

    it 'ignores activities without labels' do
      subject.scheduled_events.collect { |se| se[:scheduled_activities] }.flatten.
        should_not include('0104b')
    end

    it 'ignores non-event labels' do
      subject.scheduled_events
    end

    it 'is empty if the schedule is empty' do
      subject.schedule = {}
      subject.scheduled_events.should == []
    end
  end

  describe '#update_scheduled_activity_states' do
    let(:batch_update_path) { psc_url('subjects', person_id, 'schedules', 'activities') }

    let(:update_request) {
      {
        'sa_4' => { 'state' => 'canceled', 'date' => '2011-01-06', 'reason' => 'because' },
        'sa_8' => { 'state' => 'missed', 'date' => '2011-01-06', 'reason' => 'gone fishin' }
      }
    }

    context do
      before do
        sa_levels.each { |l| subject.valid[l] = true }
        stub_request(:post, batch_update_path).to_return(:status => 207, :body => {
            'sa_4' => { 'Status' => 201, 'Message' => 'DC' },
            'sa_8' => { 'Status' => 201, 'Message' => 'DC' },
          }.to_json, :headers => { 'Content-Type' => 'application/json' })
        subject.update_scheduled_activity_states(update_request)
      end

      it 'POSTs the updates' do
        WebMock.should have_requested(:post, batch_update_path).with do |req|
          requested = JSON.parse(req.body)
          requested['sa_8']['state'] == 'missed' && requested['sa_4']['reason'] == 'because'
        end
      end

      it 'invalidates the :sa_content cache level' do
        subject.valid[:sa_content].should be_false
      end

      it 'does not invalidate the :sa_list cache level' do
        subject.valid[:sa_list].should be_true
      end
    end

    describe 'when there is a partial failure' do
      before do
        stub_request(:post, batch_update_path).to_return(:status => 207, :body => {
            'sa_4' => { 'Status' => 201, 'Message' => 'DC' },
            'sa_8' => { 'Status' => 400, 'Message' => 'That is not a good state, jerk.' },
          }.to_json, :headers => { 'Content-Type' => 'application/json' })
      end

      it 'fails' do
        lambda { subject.update_scheduled_activity_states(update_request) }.
          should raise_error(PatientStudyCalendar::ResponseError,
            /sa_8, status 400: That is not a good state, jerk. \(submitted: \{.*"state".*?\}\)/)
      end
    end

    describe 'when there is an unexpected response status' do
      [400, 403, 404, 500].each do |s|
        it "fails with #{s}" do
          stub_request(:post, batch_update_path).
            to_return(:status => s, :body => 'No frob allowed')

          new_states = {
            'sa4' => { 'state' => 'occurred', 'date' => '2007-09-09', 'reason' => 'I forgot' }
          }
          lambda { subject.update_scheduled_activity_states(new_states) }.
            should raise_error(PatientStudyCalendar::ResponseError, 'No frob allowed')
        end
      end
    end
  end
end
