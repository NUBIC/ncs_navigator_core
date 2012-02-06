require 'spec_helper'

describe PatientStudyCalendar do

  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
    @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
  end

  let(:subject) { PatientStudyCalendar.new(@user) }

  it "connects to the running instance of PSC configured in by the NcsNavigator::Configuration" do
    cnx = subject.get_connection
    cnx.should_not be_nil
    cnx.class.should == Psc::Connection
  end

  it "uses the correct service url to request the cas-proxy-ticket" do
    # protocol:host_url/prefix
    service_url = "https://ncsn-psc.local/auth/cas_security_check"
    @user.should_receive(:cas_proxy_ticket).with(service_url).and_return('PT-CAS-2')
    VCR.use_cassette('psc/segments') do
      subject.segments
    end
  end

  it "gets the study identifier" do
    VCR.use_cassette('psc/study_identifier') do
      subject.study_identifier.should == "NCS Hi-Lo"
    end
  end

  it "gets the site identifier" do
    VCR.use_cassette('psc/site_identifier') do
      subject.site_identifier.should == "GCSC"
    end
  end

  it "gets the segments for the study" do
    VCR.use_cassette('psc/segments') do
      segments = subject.segments
      segments.size.should == 13
      segments.first.attr('name').should == "Pregnancy Screener"
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
      @female  = Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Female", :local_code => 2)
      @person = Factory(:person, :first_name => "Etta", :last_name => "Baker", :sex => @female, :person_dob => '1900-01-01')
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.register!
      ppg1 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
      Factory(:ppg_status_history, :participant => @participant, :ppg_status => ppg1)
    end

    context "checking if registered" do
      it "knows when the participant is NOT registered with the study" do
        VCR.use_cassette('psc/unknown_subject') do
          subject.is_registered?(@participant).should be_false
        end
      end

      it 'only checks once if the participant is NOT registered with the study' do
        pending 'This tests does not fail when the underlying feature is broken due to #1724'
        VCR.use_cassette('psc/unknown_subject') do
          subject.is_registered?(@participant).should be_false
        end
        subject.is_registered?(@participant).should be_false
      end

      it "knows when the participant IS registered with the study" do
        person = Factory(:person, :first_name => "As", :last_name => "Df", :sex => @female, :person_dob => '1900-01-01', :person_id => "asdf")
        participant = Factory(:participant)
        participant.person = person
        VCR.use_cassette('psc/known_subject') do
          subject.is_registered?(participant).should be_true
        end
      end

      it "should store the participant identifier when the participant registers" do
        person = Factory(:person, :first_name => "As", :last_name => "Df", :sex => @female, :person_dob => '1900-01-01', :person_id => "asdf")
        participant = Factory(:participant)
        participant.person = person
        VCR.use_cassette('psc/known_subject') do
          subject.is_registered?(participant).should be_true
          subject.registered_participant?(participant).should be_true
        end
      end

    end

    it "registers a participant with the study" do
      VCR.use_cassette('psc/assign_subject') do
        subject.is_registered?(@participant).should be_false
        @participant.next_study_segment.should == "LO-Intensity: Pregnancy Screener"
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
        ppg1 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
        Factory(:ppg_status_history, :participant => participant, :ppg_status => ppg1)

        participant.next_study_segment.should == "LO-Intensity: Pregnancy Screener"
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

    it "retrieves a list of all scheduled activities" do
      VCR.use_cassette('psc/scheduled_activity_report') do
        scheduled_activities = subject.scheduled_activities_report
        scheduled_activities.size.should == 2
      end
    end

    it "schedules an activity for a participant given an event type and date" do
      VCR.use_cassette('psc/known_events') do
        person = Factory(:person, :first_name => "As", :last_name => "Df", :sex => @female, :person_dob => '1900-01-01', :person_id => "asdf")
        participant = Factory(:participant, :p_id => "asdf")
        participant.person = person
        subject.schedules(participant).should be_nil
        subject.schedule_known_event(participant, "Pregnancy Probability", Date.today)

        subject_schedules = subject.schedules(participant)
        days = subject_schedules["days"]
        date = days.keys.first
        day = days[date]
        activities = day["activities"]
        activities.first["study_segment"].should == "LO-Intensity: PPG Follow-Up"
      end
    end

  end

  context "determining schedule state" do

    before(:each) do
      @female = Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Female", :local_code => 2)
      @person = Factory(:person, :first_name => "Etta", :last_name => "Baker", :sex => @female, :person_dob => '1900-01-01')
      @participant = Factory(:participant)
      @participant.person = @person
      @participant.register!
      ppg1 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
      Factory(:ppg_status_history, :participant => @participant, :ppg_status => ppg1)

      @ppgfu_event = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Probability", :local_code => 7)
      @preg_screen = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Screener", :local_code => 29)
    end

    it "knows about scheduled segments" do
      VCR.use_cassette('psc/lo_i_ppg_follow_up_pending') do
        person = Factory(:person, :first_name => "Ally", :last_name => "Goodfella", :sex => @female, :person_dob => '1980-10-31', :person_id => "allyg")
        participant = Factory(:participant, :p_id => "allyg")
        participant.person = person

        subject_schedule_status = subject.scheduled_activities(participant)
        subject_schedule_status.should_not be_nil
        subject_schedule_status.size.should == 3

        sss = subject_schedule_status.first
        sss.date.should == "2011-11-14"
        sss.study_segment.should == "LO-Intensity: PPG Follow-Up"
        sss.activity_name.should == "Pregnancy Probability Group Follow-Up Interview"
        sss.activity_id.should == "fb6249e5-2bf6-40cc-81e9-dc30e2012410"
        sss.current_state.should == PatientStudyCalendar::ACTIVITY_SCHEDULED

        sss = subject_schedule_status.last
        sss.date.should == "2011-05-07"
        sss.study_segment.should == "LO-Intensity: Pregnancy Screener"
        sss.activity_name.should == "Pregnancy Screener Interview"
        sss.current_state.should == PatientStudyCalendar::ACTIVITY_OCCURRED
      end
    end

    it "can determine if activities are to be rescheduled" do
      VCR.use_cassette('psc/lo_i_ppg_follow_up_pending') do
        person = Factory(:person, :first_name => "Ally", :last_name => "Goodfella", :sex => @female, :person_dob => '1980-10-31', :person_id => "allyg")
        participant = Factory(:participant, :p_id => "allyg")
        participant.person = person

        subject.activities_to_reschedule(participant, @preg_screen.to_s).should be_nil
        subject.activities_to_reschedule(participant, @ppgfu_event.to_s).should == ["fb6249e5-2bf6-40cc-81e9-dc30e2012410", "bfb76131-58cd-4db5-b0df-17b82fd2de17"]
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

  context "determining the instruments for an event" do

    context "a new ppg 2 participant" do

      let(:status1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 1: Pregnant", :local_code => 1) }
      let(:status2) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
      let(:status2a) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }

      let(:female) { Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Female", :local_code => 2) }

      let(:preg_screen) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Screener", :local_code => 29) }
      let(:lo_i_quex) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Low Intensity Data Collection", :local_code => 33) }
      let(:informed_consent) { Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Informed Consent", :local_code => 10) }

      let(:date) { "2012-02-06" }

      before(:each) do
        @person = Factory(:person, :first_name => "Jane", :last_name => "Doe", :sex => female, :person_dob => '1980-02-14', :person_id => "janedoe_ppg2")
        @participant = Factory(:participant, :p_id => "janedoe_ppg2")
        @participant.person = @person
        @participant.save!

        Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => date, :event_type => preg_screen)
        @lo_i_quex = Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => nil, :event_type => lo_i_quex)
        Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => date, :event_type => preg_screen)
        @informed_consent = Factory(:event, :participant => @participant, :event_start_date => date, :event_end_date => nil, :event_type => informed_consent)

      end

      describe "#activities_for_pending_events" do

        it "returns the instrument labels from psc for the given participant's pending events" do
          VCR.use_cassette('psc/janedoe_ppg2_new_participant') do
            Factory(:ppg_detail, :participant => @participant, :ppg_first => status2)
            Factory(:ppg_status_history, :participant => @participant, :ppg_status => status2a)

            @participant.pending_events.should == [@lo_i_quex, @informed_consent]

            subject_schedule_status = subject.scheduled_activities(@participant)
            subject_schedule_status.size.should == 3

            activities_for_pending_events = subject.activities_for_pending_events(@participant)
            activities_for_pending_events.size.should == 2

            sss = subject_schedule_status[0]
            sss.study_segment.should == "LO-Intensity: PPG 1 and 2"
            sss.labels.should == "event:informed_consent"
            sss.ideal_date.should == date
            sss.activity_name.should == "Low-Intensity Consent"

            sss = subject_schedule_status[1]
            sss.study_segment.should == "LO-Intensity: PPG 1 and 2"
            sss.labels.should == "event:low_intensity_data_collection instrument:ins_que_lipregnotpreg_int_li_p2_v2.0"
            sss.ideal_date.should == date
            sss.activity_name.should == "Low-Intensity Interview"

            sss = subject_schedule_status[2]
            sss.study_segment.should == "LO-Intensity: Pregnancy Screener"
            sss.labels.should == "event:pregnancy_screener instrument:ins_que_pregscreen_int_hili_p2_v2.0"
            sss.ideal_date.should == date
            sss.activity_name.should == "Pregnancy Screener Interview"

            activities_for_pending_events[0].should == subject_schedule_status[0]
            activities_for_pending_events[1].should == subject_schedule_status[1]
          end
        end

      end



    end

  end

end
