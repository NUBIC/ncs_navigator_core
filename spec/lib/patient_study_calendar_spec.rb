require 'spec_helper'

describe PatientStudyCalendar do

  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
  end

  it "connects to the running instance of PSC configured in by the NcsNavigator::Configuration" do
    cnx = PatientStudyCalendar.get_connection
    cnx.should_not be_nil
    cnx.class.should == Psc::Connection
  end

  
  it "gets the study identifier" do
    VCR.use_cassette('psc/study_identifier') do
      PatientStudyCalendar.study_identifier.should == "NCS Hi-Lo"
    end
  end

  it "gets the site identifier" do
    VCR.use_cassette('psc/site_identifier') do
      PatientStudyCalendar.site_identifier.should == "GCSC"
    end
  end

  it "gets the segments for the study" do
    VCR.use_cassette('psc/segments') do
      segments = PatientStudyCalendar.segments
      segments.size.should == 13
      segments.first.attr('name').should == "Pregnancy Screener"
    end
  end
  
  context "with a participant" do
  
    before(:each) do
      @female  = Factory(:ncs_code, :list_name => "GENDER_CL1", :display_text => "Female", :local_code => 2)
      @person = Factory(:person, :first_name => "Etta", :last_name => "Baker", :sex => @female, :person_dob => '1900-01-01')
      @participant = Factory(:participant, :person => @person)
      ppg1 = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1)
      Factory(:ppg_status_history, :participant => @participant, :ppg_status => ppg1)
    end
  
    context "checking if registered" do
      it "knows when the participant is NOT registered with the study" do
        VCR.use_cassette('psc/unknown_subject') do
          PatientStudyCalendar.is_registered?(@participant).should be_false
        end
      end
      
      it "knows when the participant IS registered with the study" do
        person = Factory(:person, :first_name => "As", :last_name => "Df", :sex => @female, :person_dob => '1900-01-01', :person_id => "asdf")
        participant = Factory(:participant, :person => person)
        VCR.use_cassette('psc/known_subject') do
          PatientStudyCalendar.is_registered?(participant).should be_true
        end
      end
    end
    
    it "registers a participant with the study" do
      VCR.use_cassette('psc/assign_subject') do
        resp = PatientStudyCalendar.assign_subject(@participant)
        resp.headers["location"].should == "#{@uri}api/v1/studies/NCS+Hi-Lo/schedules/todo"
      end
    end
  
  end
  
  
  context "calling api" do
    
    it "parses subject schedules" do
      json = File.open("#{Rails.root}/spec/fixtures/json/psc_subject_schedules.json", "r").read
      subject_schedules = JSON.parse(json)
      subject_schedules.class.should == Hash
      subject = subject_schedules["subject"]
      subject["full_name"].should == "Ella Fitzgerald"
      days = subject_schedules["days"]
      days.size.should == 1
      days.keys.size.should == 1
      date = days.keys.first
      date.should == "2011-08-29"
      day = days[date]
      activities = day["activities"]
      activities.size.should == 1
      activities.first["study_segment"].should == "LO-Intensity: Pregnancy Screener"
      activities.first["assignment"]["id"].should == "todo_1314638760" 
    end
    
  end
  
end