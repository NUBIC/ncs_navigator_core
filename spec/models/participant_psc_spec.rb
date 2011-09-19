require 'spec_helper'

describe Participant do

  context "a new participant" do
    
    it "has no upcoming event until it is registered with the Patient Study Calendar (PSC)" do
      
      participant = Factory(:participant)
      participant.should be_pending
      participant.next_study_segment.should be_nil
      
      participant.next_scheduled_event.should be_nil

    end
    
  end
  
  context "in the low intensity arm" do
  
    context "a registered participant" do

      let(:participant) { Factory(:participant) }

      before(:each) do
        participant.register!
      end
    
      it "is scheduled for the LO-Intensity Pregnancy Screener event on that day" do
        participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PREGNANCY_SCREENER
        participant.next_scheduled_event.event.should == participant.next_study_segment
        participant.next_scheduled_event.date.should == Date.today
      end
  
    end
  
    context "assigned to a pregnancy probability group" do
  
      context "PPG Group 1: Pregnant and Eligible" do
  
        let(:participant) { Factory(:low_intensity_ppg1_participant) }
    
        it "is to be scheduled for the LO-Intensity PPG 1 and 2 event on that day" do
          participant.ppg_status.local_code.should == 1
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2 
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == Date.today
        end
        
        it "is to be scheduled for the LO-Intensity Birth Visit Interview if consented and known to be pregnant the day after the due_date" do
          participant.should be_in_pregnancy_probability_group
          participant.should be_known_to_be_pregnant
          participant.impregnate!
          
          participant.stub!(:due_date).and_return { 270.days.from_now.to_date }
          
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_BIRTH_VISIT_INTERVIEW
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == 271.days.from_now.to_date
          
        end
    
      end
    
      context "PPG Group 2: High Probability - Trying to Conceive" do
  
        let(:participant) { Factory(:low_intensity_ppg2_participant) }
    
        it "is to be scheduled for the LO-Intensity PPG 1 and 2 event on that day" do
          participant.ppg_status.local_code.should == 2
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_1_AND_2 
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == Date.today
        end
    
      end
    
      context "PPG Group 3: High Probability - Recent Pregnancy Loss" do
        let(:participant) { Factory(:low_intensity_ppg3_participant) }
    
        it "is to be scheduled for the LO-Intensity PPG Follow Up event 6 months out" do
          participant.ppg_status.local_code.should == 3
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == 6.months.from_now.to_date
        end
      end
      
      context "PPG Group 4: Other Probability - Not Pregnant and not Trying" do
        let(:participant) { Factory(:low_intensity_ppg4_participant) }
    
        it "is to be scheduled for the LO-Intensity PPG Follow Up event 6 months out" do
          participant.ppg_status.local_code.should == 4
          participant.should be_in_pregnancy_probability_group
          participant.next_study_segment.should == PatientStudyCalendar::LOW_INTENSITY_PPG_FOLLOW_UP
          participant.next_scheduled_event.event.should == participant.next_study_segment
          participant.next_scheduled_event.date.should == 6.months.from_now.to_date
        end
      end
      
      
    end
    
  end

end