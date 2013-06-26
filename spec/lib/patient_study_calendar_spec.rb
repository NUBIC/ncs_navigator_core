# -*- coding: utf-8 -*-

require 'logger'
require 'spec_helper'
require 'stringio'
require 'webmock/rspec'

describe PatientStudyCalendar do
  let(:template_snapshot_file) {
    File.expand_path(File.expand_path('../../fixtures/psc/current_hilo_template_snapshot.xml', __FILE__))
  }

  let(:logio) { StringIO.new }
  let(:logger) { Logger.new(logio) }
  let(:log) { logio.string }

  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
    @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")
  end

  subject { PatientStudyCalendar.new(@user, logger) }

  def psc_url(*parts)
    [
      NcsNavigator.configuration.psc_uri.to_s.sub(%r{/$}, ''),
      'api', 'v1',
      parts
    ].flatten.join('/')
  end

  def use_template_snapshot_cassette
    VCR.use_cassette(
      'psc/template_snapshot', :erb => { :snapshot_file => template_snapshot_file }
    ) do
      yield
    end
  end

  describe '#responsible_user' do
    it 'defaults to user.username' do
      subject.responsible_user.should == 'dude'
    end

    it 'is settable' do
      subject.responsible_user = 'someone-else'

      subject.responsible_user.should == 'someone-else'
    end
  end

  describe "#activities_for_event" do
    it "returns an empty array if the event participant is nil" do
      event = Factory(:event, :participant => nil)
      subject.activities_for_event(event).should == []
    end
  end

  it "connects to the running instance of PSC configured in by the NcsNavigator::Configuration" do
    cnx = subject.get_connection
    cnx.should_not be_nil
    cnx.class.should == Psc::Connection
  end

  it "uses the correct service url to request the cas-proxy-ticket" do
    # protocol:host_url/prefix
    service_url = "https://ncsn-psc.local/auth/cas_security_check"
    @user.should_receive(:cas_proxy_ticket).with(service_url).and_return('PT-CAS-2')
    use_template_snapshot_cassette do
      subject.segments
    end
  end

  it "gets the study identifier" do
    VCR.use_cassette('psc/study_identifier') do
      subject.study_identifier.should == "NCS Hi-Lo"
    end
  end

  it "use the PSU ID for the PSC site identifier" do
    subject.site_identifier.should == '20000030'
  end

  it "gets the segments for the study" do
    use_template_snapshot_cassette do
      segments = subject.segments
      segments.size.should == 19
      segments.first.attr('name').should == "Pregnancy Screener"
    end
  end

  describe '#connection' do
    describe 'retries' do
      before do
        stub_request(:get, psc_url('system-status')).
          to_return(:status => 502).times(2).then.
          to_return(:status => 200)
      end

      it 'automatically retries on failure' do
        subject.connection.get('system-status').status.should == 200
      end
    end
  end

  describe '#template_snapshot' do
    let(:template_snapshot_url) { psc_url('studies', 'NCS Hi-Lo', 'template', 'current.xml') }

    context do
      before do
        stub_request(:get, template_snapshot_url).
          to_return(
            :status => 200,
            :body => File.read(template_snapshot_file),
            :headers => { 'Content-Type' => 'text/xml' }
          ).times(1).then.to_raise('Should be called at most once')
      end

      it 'returns the parsed XML for the template' do
        subject.template_snapshot.root['assigned-identifier'].should == 'NCS Hi-Lo'
      end

      it 'caches the template' do
        subject.template_snapshot
        lambda { subject.template_snapshot }.should_not raise_error
      end
    end

    describe 'with an error' do
      it 'fails if the template is not found' do
        stub_request(:get, template_snapshot_url).to_return(:status => 404, :body => 'NF')

        lambda { subject.template_snapshot }.
          should raise_error(PatientStudyCalendar::ResponseError, 'NF')
      end
    end
  end

  describe '#schedule_preview' do
    let(:date) { Date.parse('2000-01-01') }

    around do |example|
      snapshot_fn = File.expand_path('../../fixtures/psc/schedule_preview.json', __FILE__)

      use_template_snapshot_cassette do
        VCR.use_cassette('psc/schedule_preview', :erb => { :snapshot_file => snapshot_fn }) { example.call }
      end
    end

    it 'raises ArgumentError if given zero study segments' do
      lambda { subject.schedule_preview(date, []) }.should raise_error(ArgumentError)
    end

    it 'retrieves a preview for the given start date and study segments' do
      study_segments = [
        PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1,
        PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
      ]

      preview = subject.schedule_preview(date, study_segments)

      # This is all VCRed, so testing body contents is pretty pointless.
      # Assuming nothing was raised and we don't get back a blank object, we're
      # likely fine.
      preview.should_not be_blank
    end
  end

  describe '#segment_uuids' do
    around do |example|
      use_template_snapshot_cassette { example.call }
    end

    it 'returns the UUID for study segments' do
      segments = [
        PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP,
        PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1
      ]

      subject.segment_uuids(segments).should == {
        PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP => '6a141368-5229-4262-b3c5-45212520ec76',
        PatientStudyCalendar::HIGH_INTENSITY_PREGNANCY_VISIT_1 => 'ca65bbbb-7e47-4f71-a4f0-071e7f73f380'
      }
    end

    it 'differentiates study segments by epoch' do
      segments = [
        PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP,
        PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP
      ]

      subject.segment_uuids(segments).should == {
        PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP => '6a141368-5229-4262-b3c5-45212520ec76',
        PatientStudyCalendar::HIGH_INTENSITY_PPG_FOLLOW_UP => 'a7068506-37db-4fe2-80ca-88f6d518b1e1'
      }
    end

    it 'does not return unresolvable labels in the mapping' do
      segments = [
        'Nothing: foo'
      ]

      subject.segment_uuids(segments).should_not have_key('Nothing: foo')
    end

    it 'does not return labels without epochs' do
      segments = [
        'foo'
      ]

      subject.segment_uuids(segments).should_not have_key('foo')
    end

    it 'logs unresolvable labels' do
      segments = [
        'foo'
      ]

      subject.segment_uuids(segments)

      log.should =~ /cannot resolve id for segment label "foo"/i
    end
  end

  it "gets the psc segment name from the mdes event type code" do
    [
      ["Pregnancy Screener", "Pregnancy Screener"],
      ["PPG 1 and 2", "Low Intensity Data Collection"],
      ["PPG Follow-Up", "Pregnancy Probability"],
      ["Birth Visit Interview", "Birth"],
      ["Low to High Conversion", "Low to High Conversion"],
      ["Pre-Pregnancy", "Pre-Pregnancy Visit"],
      ["Pregnancy Visit 1", "Pregnancy Visit  1"],
      ["Pregnancy Visit 2", "Pregnancy Visit  2"],
      # ["Child Consent", "Informed Consent"],
      # ["Father Consent and Interview", "Father"]
    ].each do |segment_name, event_type_display_text|
      PatientStudyCalendar.get_psc_segment_from_mdes_event_type(event_type_display_text).should == segment_name
    end
  end

  it "maps the psc segment name to mdes event type code" do
    [
      ["LO-Intensity: Pregnancy Screener", "Pregnancy Screener"],
      ["LO-Intensity: PPG 1 and 2", "Low Intensity Data Collection"],
      ["LO-Intensity: PPG Follow-Up", "Pregnancy Probability"],
      ["LO-Intensity: Birth Visit Interview", "Birth"],
      ["LO-Intensity: Low to High Conversion", "Low to High Conversion"],
      ["HI-Intensity: Pre-Pregnancy", "Pre-Pregnancy Visit"],
      ["HI-Intensity: Pregnancy Visit 1", "Pregnancy Visit  1"],
      ["HI-Intensity: Pregnancy Visit 2", "Pregnancy Visit 2"],
      ["HI-Intensity: Child Consent", "Informed Consent"],
      ["HI-Intensity: Father Consent and Interview", "Father"]
    ].each do |segment_name, event_type_display_text|
      PatientStudyCalendar.map_psc_segment_to_mdes_event_type(segment_name).should == event_type_display_text
    end
  end

  context "with a participant" do

    before(:each) do
      @female  = NcsCode.for_list_name_and_local_code("GENDER_CL1", 2)
      @person = Factory(:person, :first_name => "Etta", :last_name => "Baker", :sex => @female, :person_dob => '1900-01-01')
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.register!
      ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
      Factory(:ppg_status_history, :participant => @participant, :ppg_status => ppg1)
    end

    context "checking if registered" do
      it "knows when the participant is NOT registered with the study" do
        VCR.use_cassette('psc/unknown_subject') do
          subject.is_registered?(@participant).should be_false
        end
      end

      it 'can check registration status from the assignment ID directly' do
        VCR.use_cassette('psc/unknown_subject') do
          subject.is_registered?(@person.public_id).should be_false
        end
      end

      it 'only checks once if the participant is NOT registered with the study' do
        pending 'This tests does not fail when the underlying feature is broken due to #1724'
        VCR.use_cassette('psc/unknown_subject') do
          subject.is_registered?(@participant).should be_false
        end
        subject.is_registered?(@participant).should be_false
      end

      describe 'when is registered' do
        let(:person) {
          Factory(:person, :first_name => "As", :last_name => "Df",
            :sex => @female, :person_dob => '1900-01-01', :person_id =>
            "asdf")
        }

        let(:participant) {
          Factory(:participant).tap do |p|
            p.person = person
          end
        }

        it "knows when the participant IS registered with the study" do
          VCR.use_cassette('psc/known_subject') do
            subject.is_registered?(participant).should be_true
          end
        end

        it 'can check from the assignment ID directly' do
          VCR.use_cassette('psc/known_subject') do
            subject.is_registered?(person.public_id).should be_true
          end
        end

        it "should store the participant identifier when the participant registers" do
          VCR.use_cassette('psc/known_subject') do
            subject.is_registered?(participant).should be_true
            subject.registered_participant?(participant).should be_true
          end
        end
      end

    end

    it "registers a participant with the study" do
      VCR.use_cassette('psc/assign_subject') do
        subject.is_registered?(@participant).should be_false
        @participant.next_study_segment.should include("Pregnancy Screener")
        resp = subject.assign_subject(@participant)
        resp.headers["location"].should == "#{@uri}api/v1/studies/NCS+Hi-Lo/schedules/todo"
      end
    end

    it "uses the participant public_id as the assignment identifier" do
      VCR.use_cassette('psc/assignment_identfier') do

        person = Factory(:person, :first_name => "Angela", :last_name => "Davis", :sex => @female, :person_dob => '1940-01-01')
        participant = Factory(:participant, :p_id => "angela_davis_public_id")
        participant.person = person
        participant.register!
        ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
        Factory(:ppg_status_history, :participant => participant, :ppg_status => ppg1)

        participant.next_study_segment.should include("Pregnancy Screener")
        resp = subject.assign_subject(participant)

        resp = subject.assignment_identifier(participant)
        subject_assignments = resp.search('subject-assignment')
        subject_assignments.size.should == 1
        subject_assignments.first['id'].should == participant.public_id
      end
    end

    it "pulls a registered subjects schedules" do
      VCR.use_cassette('psc/schedules') do
        person = Factory(:person, :first_name => "As", :last_name => "Df", :sex => @female, :person_dob => '1900-01-01', :person_id => "asdf")
        participant = Factory(:participant)
        participant.person = person
        subject_schedules = subject.schedules(participant)
        subject_schedules.class.should == Hash
        subject = subject_schedules["subject"]
        subject["full_name"].should == "Ella Fitzgerald"
        days = subject_schedules["days"]
        days.size.should == 1
        days.keys.size.should == 1
        date = days.keys.first
        day = days[date]
        activities = day["activities"]
        activities.size.should == 1
        activities.first["study_segment"].should == "LO-Intensity: Pregnancy Screener"
        activities.first["assignment"]["id"].should == "todo_1314638760"
      end
    end

  end

  context "determining schedule state" do

    before(:each) do
      @female = NcsCode.for_list_name_and_local_code("GENDER_CL1", 2)
      @person = Factory(:person, :first_name => "Etta", :last_name => "Baker", :sex => @female, :person_dob => '1900-01-01')
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.register!
      ppg1 = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 1)
      Factory(:ppg_status_history, :participant => @participant, :ppg_status => ppg1)

      @ppgfu_event = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 7)
      @preg_screen = NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 29)
    end

    it "knows about scheduled segments" do
      VCR.use_cassette('psc/lo_i_ppg_follow_up_pending') do
        person = Factory(:person, :first_name => "Ally", :last_name => "Goodfella", :sex => @female, :person_dob => '1980-10-31', :person_id => "allyg")
        participant = Factory(:participant, :p_id => "allyg")
        participant.person = person

        subject_schedule_status = subject.scheduled_activities(participant)
        subject_schedule_status.should_not be_nil
        subject_schedule_status.size.should == 2

        sss = subject_schedule_status.first
        sss.date.should == "2011-11-14"
        sss.study_segment.should == "LO-Intensity: PPG Follow-Up"
        sss.activity_name.should == "Pregnancy Probability Group Follow-Up Interview"
        sss.activity_id.should == "fb6249e5-2bf6-40cc-81e9-dc30e2012410"
        sss.current_state.should == Psc::ScheduledActivity::SCHEDULED

        sss = subject_schedule_status.last
        sss.date.should == "2011-11-14"
        sss.study_segment.should == "LO-Intensity: PPG Follow-Up"
        sss.activity_name.should == "Pregnancy Probability Group Follow-Up SAQ"
        sss.activity_id.should == "bfb76131-58cd-4db5-b0df-17b82fd2de17"
        sss.current_state.should == Psc::ScheduledActivity::SCHEDULED
      end
    end

    it 'accepts a participant person ID directly' do
      VCR.use_cassette('psc/lo_i_ppg_follow_up_pending') do
        subject.scheduled_activities(@person.public_id).should_not be_nil
      end
    end
  end

  context "extracting the scheduled study segment id from a response from PSC" do

    describe "#extract_scheduled_study_segment_identifier" do

      it "gets the identifier" do
        body = Nokogiri::XML(<<-XML)
        <?xml version="1.0" encoding="UTF-8"?>
        <scheduled-study-segment xmlns="http://bioinformatics.northwestern.edu/ns/psc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" id="6a2d2074-e5a8-4dc6-83ff-9ecea23efada" start-date="2012-01-19" start-day="1" study-segment-id="76025607-f7aa-41e1-8ce9-29e0793cd6d4" xsi:schemaLocation="http://bioinformatics.northwestern.edu/ns/psc http://bioinformatics.northwestern.edu/ns/psc/psc.xsd">
         <scheduled-activity id="3c008584-0b55-4e43-98e9-cb5e4738a8a5" ideal-date="2012-01-19" repetition-number="0" planned-activity-id="2b68bb5c-edde-4510-81c8-b962704bc968">
           <current-scheduled-activity-state reason="Initialized from template" date="2012-01-19" state="scheduled"/>
         </scheduled-activity>
         <scheduled-activity id="6f223054-6d5b-4b66-9c14-00571272d803" ideal-date="2012-01-19" repetition-number="0" planned-activity-id="bbb8de5c-a025-4b4c-b7d2-577a96551263">
           <current-scheduled-activity-state reason="Initialized from template" date="2012-01-19" state="scheduled"/>
         </scheduled-activity>
        </scheduled-study-segment>
        XML

        PatientStudyCalendar.extract_scheduled_study_segment_identifier(body).should == "6a2d2074-e5a8-4dc6-83ff-9ecea23efada"

      end

    end

  end

  context "getting the scheduled activities for a newly scheduled segment" do

    describe "#activities_for_scheduled_segment" do

      it "returns an array of ScheduledActivities for the given event" do

        person = Factory(:person, :first_name => "Jane", :last_name => "Doe", :person_dob => '1980-02-14',
                         :person_id => "newly_scheduled_event_participant")
        participant = Factory(:participant, :p_id => "newly_scheduled_event_participant")
        participant.person = person
        participant.save!

        event = Factory(:event, :participant => participant,
                         :event_start_date => "2012-02-06", :event_end_date => nil,
                         :scheduled_study_segment_identifier => "a5fd83f9-e2ca-4481-8ce3-70406dfbcddc")

        VCR.use_cassette('psc/activities_for_newly_scheduled_event') do
          activities = subject.activities_for_scheduled_segment(participant, event.scheduled_study_segment_identifier)
          activities.size.should == 2
          activities.each do |a|
            a.ideal_date.should == event.event_start_date.to_s
          end
          activities.first.labels.should_not eql(activities.last.labels)
        end
      end

    end
  end

  context "getting the scheduled activities for the birth/child segment" do

    before(:each) do
      @person = Factory(:person, :first_name => "Francesca", :last_name => "Zupicich", :person_dob => '1980-02-14',
                       :person_id => "child_segment_participant")
      @participant = Factory(:participant, :p_id => "child_segment_participant")
      @participant.person = @person
      @participant.save!

      @event = Factory(:event, :participant => @participant,
                       :event_start_date => "2012-08-09", :event_end_date => nil,
                       :scheduled_study_segment_identifier => "f699ac2e-9784-48b7-bfc6-229e54d233b7")
    end

    describe "#activities_for_scheduled_segment" do

      it "returns all ScheduledActivities" do

        VCR.use_cassette('psc/activities_for_child_segment') do
          activities = subject.activities_for_scheduled_segment(@participant, @event.scheduled_study_segment_identifier)
          activities.size.should == 16
          event_labels = activities.map(&:labels).collect{ |l| Event.parse_label(l) }
          ["birth", "3_month", "6_month", "9_month", "12_month"].each { |l| event_labels.should include(l) }
          event_dates = activities.map(&:ideal_date).uniq
          ["2012-08-09", "2012-11-08", "2013-02-07", "2013-05-09", "2013-08-09", "2014-02-07", "2014-08-08"].each do |dt|
            event_dates.should include(dt)
          end
        end

      end
    end

    describe "#unique_label_ideal_date_pairs_for_scheduled_segment" do

      it "returns all label ideal date pairs" do
        VCR.use_cassette('psc/activities_for_child_segment') do
          label_ideal_date_pairs = subject.unique_label_ideal_date_pairs_for_scheduled_segment(@participant, @event.scheduled_study_segment_identifier)
          label_ideal_date_pairs.size.should == 7
          [ ["birth", "2012-08-09"],
            ["3_month", "2012-11-08"],
            ["6_month", "2013-02-07"],
            ["9_month", "2013-05-09"],
            ["12_month", "2013-08-09"],
            ["18_month", "2014-02-07"],
            ["24_month", "2014-08-08"]
          ].each do |l_dt|
            label_ideal_date_pairs.should include(l_dt)
          end
        end
      end
    end

  end

  context "determining the instruments for an event" do

    context "a new ppg 2 participant" do

      let(:status1) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1) }
      let(:status2) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 2) }
      let(:status2a) { NcsCode.for_list_name_and_local_code("PPG_STATUS_CL1", 2) }

      let(:female) { NcsCode.for_list_name_and_local_code("GENDER_CL1", 2) }

      let(:preg_screen) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 29) }
      let(:lo_i_quex) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 33) }
      let(:informed_consent) { NcsCode.for_list_name_and_local_code("EVENT_TYPE_CL1", 10) }

      let(:date) { "2012-02-06" }

      before(:each) do
        @person = Factory(:person, :first_name => "Jane", :last_name => "Doe", :sex => female, :person_dob => '1980-02-14', :person_id => "janedoe_ppg2")
        @participant = Factory(:participant, :p_id => "janedoe_ppg2")
        @participant.person = @person
        @participant.save!

        Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => date, :event_type => preg_screen)
        @lo_i_quex = Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => nil, :event_type => lo_i_quex)
        @informed_consent = Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => nil, :event_type => informed_consent)

      end

      describe ".scheduled_activities" do
        it "returns only scheduled activities" do
          VCR.use_cassette('psc/janedoe_canceled_activities') do
            Factory(:ppg_detail, :participant => @participant, :ppg_first => status2)
            Factory(:ppg_status_history, :participant => @participant, :ppg_status => status2a)

            subject_schedule_status = subject.scheduled_activities(@participant)
            subject_schedule_status.size.should == 1

            sss = subject_schedule_status[0]
            sss.study_segment.should == "LO-Intensity: PPG 1 and 2"
            sss.labels.should == "event:low_intensity_data_collection instrument:2.0:ins_que_lipregnotpreg_int_li_p2_v2.0"
            sss.ideal_date.should == date
            sss.activity_name.should == "Low-Intensity Interview"
            sss.current_state.should == Psc::ScheduledActivity::SCHEDULED
          end
        end
        it 'returns occurred scheduled activities' do
          VCR.use_cassette('psc/janedoe_canceled_activities') do
            subject_occurred_statuses = subject.scheduled_activities(@participant, [Psc::ScheduledActivity::OCCURRED])
            subject_occurred_statuses.size.should == 1
            sss = subject_occurred_statuses.first
            sss.current_state.should == Psc::ScheduledActivity::OCCURRED
          end
        end
      end

      describe "#activities_for_pending_events" do

        it "returns the instrument labels from psc for the given participant's pending events" do
          VCR.use_cassette('psc/janedoe_ppg2_new_participant') do
            Factory(:ppg_detail, :participant => @participant, :ppg_first => status2)
            Factory(:ppg_status_history, :participant => @participant, :ppg_status => status2a)

            [@lo_i_quex, @informed_consent].each { |e| @participant.pending_events.should include(e) }

            activities_for_pending_events = subject.activities_for_pending_events(@participant)
            activities_for_pending_events.size.should == 2

            sss = activities_for_pending_events[0]
            sss.study_segment.should == "LO-Intensity: PPG 1 and 2"
            sss.labels.should == "event:informed_consent"
            sss.ideal_date.should == date
            sss.activity_name.should == "Low-Intensity Consent"

            sss = activities_for_pending_events[1]
            sss.study_segment.should == "LO-Intensity: PPG 1 and 2"
            sss.labels.should == "event:low_intensity_data_collection instrument:2.0:ins_que_lipregnotpreg_int_li_p2_v2.0"
            sss.ideal_date.should == date
            sss.activity_name.should == "Low-Intensity Interview"

          end
        end

      end

    end

  end

  describe '#psc_participant' do
    let(:p) { Factory(:participant, :p_id => p_id) }
    let(:p_id) { 'p_54' }

    let(:person) { Factory(:person) }

    before do
      p.person = person
    end

    it 'returns a PscParticipant' do
      subject.psc_participant(p).should be_a(PscParticipant)
    end

    it 'is initialized with the participant' do
      subject.psc_participant(p).participant.should be p
    end

    it 'is initialized with a reference to the parent PatientStudyCalendar instance' do
      subject.psc_participant(p).psc.should be subject
    end

    it 'is cached' do
      subject.psc_participant(p).should be subject.psc_participant(p)
    end
  end
end
