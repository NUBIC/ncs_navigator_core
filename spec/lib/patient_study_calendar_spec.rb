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
      
      it "knows when the participant IS registered with the study" do
        person = Factory(:person, :first_name => "As", :last_name => "Df", :sex => @female, :person_dob => '1900-01-01', :person_id => "asdf")
        participant = Factory(:participant)
        participant.person = person
        VCR.use_cassette('psc/known_subject') do
          subject.is_registered?(participant).should be_true
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
        subject_assignments = resp.body.search('subject-assignment')
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
  
end