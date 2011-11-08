require 'spec_helper'

describe Participant do
  
  before(:each) do
    psc_config ||= NcsNavigator.configuration.instance_variable_get("@application_sections")["PSC"]
    @uri  = psc_config["uri"]
    @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")
  end
  
  let(:psc) { PatientStudyCalendar.new(@user) }

  context "after completing the Pregnancy Screener Instrument" do

    let(:participant) { Factory(:participant, :low_intensity_state => 'registered') }
    
    let(:survey) { Factory(:survey, :title => "_PregScreen_") }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => participant.person) }
    
    it "should assign the participant into a pregnancy probability group" do
      participant.should be_registered
      psc.should_receive(:update_subject).with(participant).and_return(true)
      participant.update_state_after_survey(response_set, psc)
      participant.should be_in_pregnancy_probability_group
    end
    
  end
  
  context "after completing the Low Intensity Questionnaire Instrument" do

    let(:participant) { Factory(:participant, :low_intensity_state => 'in_pregnancy_probability_group') }
    
    let(:survey) { Factory(:survey, :title => "_LIPregNotPreg_") }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => participant.person) }
    
    it "should be following the low intensity participant" do
      participant.should be_in_pregnancy_probability_group
      participant.update_state_after_survey(response_set, psc)
      participant.should be_following_low_intensity
    end
    
  end
  
  context "after completing the Low to High Conversion" do

    let(:participant) { Factory(:participant, :low_intensity_state => 'in_pregnancy_probability_group') }
    
    let(:survey) { Factory(:survey, :title => "_LIHIConversion_") }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => participant.person) }
    
    it "moves the participant into the high intensity arm" do
      participant.should be_in_pregnancy_probability_group
      participant.update_state_after_survey(response_set, psc)
      participant.should be_moved_to_high_intensity_arm
    end
    
    describe "a non-pregnant consented participant" do
      it "moves to the high intensity non pregnant consented state" do
        participant.should be_in_pregnancy_probability_group
        participant.should_receive(:consented?).and_return(true)
        participant.update_state_after_survey(response_set, psc)
        participant.should be_pre_pregnancy      
      end
    end
    
    describe "a pregnant consented participant" do
      it "moves to the high intensity pregnancy one state" do
        participant.should be_in_pregnancy_probability_group
        participant.should_receive(:consented?).and_return(true)
        participant.should_receive(:can_high_intensity_consent?).and_return(true)
        2.times do
          participant.should_receive(:known_to_be_pregnant?).and_return(true)
        end
        participant.should_receive(:can_impregnate?).and_return(true)
        participant.update_state_after_survey(response_set, psc)
        participant.should be_pregnancy_one
      end
    end
  end
  
  context "after completing the Pregnancy One Visit" do
    
    let(:participant) { Factory(:participant, :high_intensity_state => 'pregnancy_one') }
    
    let(:survey) { Factory(:survey, :title => "_PregVisit1_") }
    let(:response_set) { Factory(:response_set, :survey => survey, :person => participant.person) }
    
    describe "a high intensity pregnant participant" do
      it "moves to the high intensity pregnancy two state" do
        participant.should be_pregnancy_one
        participant.update_state_after_survey(response_set, psc)
        participant.should be_pregnancy_two
      end
    end
    
  end


end