# == Schema Information
# Schema version: 20110805151543
#
# Table name: participants
#
#  id                       :integer         not null, primary key
#  psu_code                 :string(36)      not null
#  p_id                     :binary          not null
#  person_id                :integer         not null
#  p_type_code              :integer         not null
#  p_type_other             :string(255)
#  status_info_source_code  :integer         not null
#  status_info_source_other :string(255)
#  status_info_mode_code    :integer         not null
#  status_info_mode_other   :string(255)
#  status_info_date         :date
#  enroll_status_code       :integer         not null
#  enroll_date              :date
#  pid_entry_code           :integer         not null
#  pid_entry_other          :string(255)
#  pid_age_eligibility_code :integer         not null
#  pid_comment              :text
#  transaction_type         :string(36)
#  created_at               :datetime
#  updated_at               :datetime
#  being_processed          :boolean
#

require 'spec_helper'

describe Participant do
  
  it "creates a new instance given valid attributes" do
    par = Factory(:participant)
    par.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:person) }
  it { should belong_to(:p_type) }
  it { should belong_to(:status_info_source) }
  it { should belong_to(:status_info_mode) }
  it { should belong_to(:enroll_status) }
  it { should belong_to(:pid_entry) }
  it { should belong_to(:pid_age_eligibility) }
  
  it { should have_many(:ppg_details) }
  it { should have_many(:ppg_status_histories) }

  it { should validate_presence_of(:person) }
  
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      pr = Factory(:participant)
      pr.public_id.should_not be_nil
      pr.p_id.should == pr.public_id
      pr.p_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Participant)
      
      pr = Participant.new
      pr.psu = Factory(:ncs_code)
      pr.person = Factory(:person)
      pr.save!
    
      obj = Participant.find(pr.id)
      obj.status_info_source.local_code.should == -4
      obj.pid_entry.local_code.should == -4
      obj.p_type.local_code.should == -4
      obj.status_info_source.local_code.should == -4
      obj.status_info_mode.local_code.should == -4
      obj.enroll_status.local_code.should == -4
      obj.pid_entry.local_code.should == -4
      obj.pid_age_eligibility.local_code.should == -4
    end
  end
  
  context "delegating to the associated person" do
    let(:person) { Factory(:person, :person_dob_date => 10.years.ago) }
    let(:participant) { Factory(:participant, :person => person) }
    
    it "returns age" do
      participant.age.should == person.age
    end
    
    it "returns first_name" do
      participant.first_name.should == person.first_name
    end
    
    it "returns last_name" do
      participant.last_name.should == person.last_name
    end
    
  end

  context "with an assigned pregnancy probability group" do
    
    let(:participant) { Factory(:participant) }
    let(:status1)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
    let(:status2)  { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
    let(:status2a) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL2", :display_text => "PPG Group 2: High Probability – Trying to Conceive", :local_code => 2) }
    
    it "determines the ppg from the ppg_details if there is no ppg_status_history record" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a)
      
      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should be_empty
      participant.ppg_status.should == status2a   
    end

    it "determines the ppg from the ppg_status_history" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a)
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)
      
      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should_not be_empty
      participant.ppg_status.should == status1
    end
    
    it "determines the ppg from the most recent ppg_status_history" do
      Factory(:ppg_detail, :participant => participant, :ppg_first => status2a)
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status2,  :ppg_status_date => '2011-01-02')
      Factory(:ppg_status_history, :participant => participant, :ppg_status => status1, :ppg_status_date => '2011-01-31')
      
      participant.ppg_details.should_not be_empty
      participant.ppg_status_histories.should_not be_empty
      participant.ppg_status.should == status1
    end
    
  end

  context "hi/lo recruitment strategy" do
    
    it "should know if in the high intensity protocol" do
      participant = Factory(:participant)
      hi = Factory(:ncs_code, :list_name => "PARTICIPANT_STATUS_CL1", :display_text => "Enrolled in regular intensity protocol", :local_code => 2)
      Factory(:ppg_detail, :participant => participant, :ppg_pid_status => hi)
      participant.protocol_status.should == hi
    end
    
    it "should know if in the low intensity protocol" do
      participant = Factory(:participant)
      lo = Factory(:ncs_code, :list_name => "PARTICIPANT_STATUS_CL1", :display_text => "Enrolled in low intensity protocol", :local_code => 3)
      Factory(:ppg_detail, :participant => participant, :ppg_pid_status => lo)
      participant.protocol_status.should == lo
    end
    
  end

  
  context "determining schedule" do
    
    describe "a participant who has had a recent pregnancy loss - PPG 3" do

      before(:each) do
        status = Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 3: High Probability – Recent Pregnancy Loss", :local_code => 3)
        @participant = Factory(:participant)
        Factory(:ppg_status_history, :participant => @participant, :ppg_status => status)
      end
      
      it "knows the upcoming applicable events for a new participant" do
        @participant.ppg_status.local_code.should == 3
        @participant.next_scheduled_event.event.should == "Pregnancy Probability"
        @participant.next_scheduled_event.date.should == 3.months.from_now.to_date
      end
      
      it "knows the upcoming applicable events for a participant who has had a followup already" do
        event_type = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Probability", :local_code => 7)
        event_disposition_category = Factory(:ncs_code, :list_name => "EVENT_DSPSTN_CAT_CL1",  :display_text => "Telephone Interview Events", :local_code => 5)
        event = Factory(:event, :event_type => event_type, :event_disposition_category => event_disposition_category)
        contact = Factory(:contact)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 2.months.ago)
        
        @participant.next_scheduled_event.event.should == "Pregnancy Probability"
        @participant.next_scheduled_event.date.should == 1.month.from_now.to_date
      end
      
      it "knows the upcoming applicable events for a participant who has had several followups already" do
        event_type = Factory(:ncs_code, :list_name => "EVENT_TYPE_CL1", :display_text => "Pregnancy Probability", :local_code => 7)
        event_disposition_category = Factory(:ncs_code, :list_name => "EVENT_DSPSTN_CAT_CL1",  :display_text => "Telephone Interview Events", :local_code => 5)
        event = Factory(:event, :event_type => event_type, :event_disposition_category => event_disposition_category)
        contact = Factory(:contact)
        
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 10.month.ago)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 7.month.ago)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 4.month.ago)
        contact_link = Factory(:contact_link, :person => @participant.person, :event => event, :created_at => 1.month.ago)
        
        @participant.next_scheduled_event.event.should == "Pregnancy Probability"
        @participant.next_scheduled_event.date.should == 2.month.from_now.to_date
      end
      
      context "in the low intensity protocol" do
        
        it "knows the upcoming applicable events for a new participant" do
          lo = Factory(:ncs_code, :list_name => "PARTICIPANT_STATUS_CL1", :display_text => "Enrolled in low intensity protocol", :local_code => 3)
          Factory(:ppg_detail, :participant => @participant, :ppg_pid_status => lo)
          @participant.next_scheduled_event.event.should == "Pregnancy Probability"
          @participant.next_scheduled_event.date.should == 6.months.from_now.to_date
        end
        
        
        
      end
      
    end
    
  end

  
end
