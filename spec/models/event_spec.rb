# == Schema Information
# Schema version: 20111018175121
#
# Table name: events
#
#  id                              :integer         not null, primary key
#  psu_code                        :integer         not null
#  event_id                        :binary          not null
#  participant_id                  :integer
#  event_type_code                 :integer         not null
#  event_type_other                :string(255)
#  event_repeat_key                :integer
#  event_disposition               :integer
#  event_disposition_category_code :integer         not null
#  event_start_date                :date
#  event_start_time                :string(255)
#  event_end_date                  :date
#  event_end_time                  :string(255)
#  event_breakoff_code             :integer         not null
#  event_incentive_type_code       :integer         not null
#  event_incentive_cash            :decimal(3, 2)
#  event_incentive_noncash         :string(255)
#  event_comment                   :text
#  transaction_type                :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#

require 'spec_helper'

describe Event do  
  
  it "should create a new instance given valid attributes" do
    e = Factory(:event)
    e.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:event_type) }
  it { should belong_to(:event_disposition_category) }
  it { should belong_to(:event_breakoff) }
  it { should belong_to(:event_incentive_type) }
  
  it "knows when it is 'closed'" do
    e = Factory(:event)
    e.should_not be_closed
    
    e.event_disposition = 510
    e.should be_closed
    e.should be_completed
  end
  
  context "surveys for the event" do
    
    it "knows it's Surveys" do
      event_type = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Pregnancy Screener")
      e = Factory(:event, :event_type => event_type)
      survey = Factory(:survey, :title => "INS_QUE_PregScreen_INT_HILI_P2_V2.0", :access_code => "ins-que-pregscreen-int-hili-p2-v2-0")
      e.surveys.should == [survey]
    end
  end
  
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      e = Factory(:event)
      e.public_id.should_not be_nil
      e.event_id.should == e.public_id
      e.event_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Event)
      
      e = Event.new
      e.psu = Factory(:ncs_code)
      e.participant = Factory(:participant)
      e.save!
    
      obj = Event.first
      obj.event_type.local_code.should == -4
      obj.event_disposition_category.local_code.should == -4
      obj.event_breakoff.local_code.should == -4
      obj.event_incentive_type.local_code.should == -4
    end
  end
  
  context "human-readable attributes" do
    it "returns the event type display text for to_s" do
      e = Factory(:event)
      e.to_s.should == e.event_type.display_text
    end
    
    it "concatenates the start date and time for the event start" do
      e = Factory(:event)
      e.event_start.should == "N/A"
      e.event_start_time = "HH:MM"
      e.event_start_date = Date.parse('2011-01-01')
      e.event_start.should == "2011-01-01 HH:MM"
    end

    it "concatenates the end date and time for the event end" do
      e = Factory(:event)
      e.event_end.should == "N/A"
      e.event_end_date = Date.parse('2011-01-01')
      e.event_end_time = "HH:MM"
      e.event_end.should == "2011-01-01 HH:MM"
    end
  end
  
  context "mapping events to psc segments" do
    
    it "should determine the segment based on the event's event type" do
      [
        ["Ongoing Tracking of Dwelling Units", nil],
        ["Pregnancy Screener", "Pregnancy Screener"],
        ["Pre-Pregnancy Visit", "Pre-Pregnancy"],
        ["Pregnancy Visit #1 SAQ", "Pregnancy Visit 1"]
      ].each do |event_type_text, psc_segment|
        event_type = Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => event_type_text)
        e = Factory(:event, :event_type => event_type)
        e.psc_segment_name.should == psc_segment
      end
    end
    
  end
  
  context "disposition" do
    
    describe "household enumeration" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 1, :display_text => "Household Enumeration Events")
      end
      
      it "knows if it is complete" do
        (540..545).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end
      
      it "knows if it is not complete" do
        [510, 515, 546, 539].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
      
    end
    
    describe "pregnancy screener" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 2, :display_text => "Pregnancy Screening Events")
      end
      
      it "knows if it is complete" do
        (560..565).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end
      
      it "knows if it is not complete" do
        [510, 515, 566, 559].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
      
    end
    
    describe "general study" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 3, :display_text => "General Study Visits (including CASI SAQs)")
      end

      it "knows if it is complete" do
        (560..562).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end
      
      it "knows if it is not complete" do
        [510, 515, 563, 559].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end

    end
    
    describe "mailed back saq" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 4, :display_text => "Mailed Back Self Administered Questionnaires")
      end
      
      it "knows if it is complete" do
        (550..556).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end
      
      it "knows if it is not complete" do
        [510, 515, 549, 557].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end
    
    describe "telephone interview" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 5, :display_text => "Telephone Interview Events")
      end
      
      it "knows if it is complete" do
        (590..595).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end
      
      it "knows if it is not complete" do
        [510, 515, 589, 596].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end
    
    describe "internet survey" do
      before(:each) do
        @cat = Factory(:ncs_code, :list_name => 'EVENT_DSPSTN_CAT_CL1', :local_code => 6, :display_text => "Internet Survey Events")
      end
      
      it "knows if it is complete" do
        (540..546).each do |complete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => complete_code)
          event.should be_disposition_complete
        end
      end
      
      it "knows if it is not complete" do
        [510, 515, 539, 547].each do |incomplete_code|
          event = Factory(:event, :event_disposition_category => @cat, :event_disposition => incomplete_code)
          event.should_not be_disposition_complete
        end
      end
    end
    
  end
end
