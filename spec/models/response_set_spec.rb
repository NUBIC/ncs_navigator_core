# == Schema Information
# Schema version: 20111110015749
#
# Table name: response_sets
#
#  id                                        :integer         not null, primary key
#  user_id                                   :integer
#  survey_id                                 :integer
#  access_code                               :string(255)
#  started_at                                :datetime
#  completed_at                              :datetime
#  created_at                                :datetime
#  updated_at                                :datetime
#  contact_link_id                           :integer
#  processed_for_operational_data_extraction :boolean
#

require 'spec_helper'

describe ResponseSet do
  
  it { should belong_to(:person) }
  it { should belong_to(:contact_link) }
  
  context "with instruments" do
    before(:each) do
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
    end

    describe "a participant who is in ppg1 - Currently Pregnant and Eligible" do
      
      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant, :person => person, :high_intensity => true, :high_intensity_state => "pregnancy_one") }
  
      let(:access_code) { "ins-que-pregvisit1-int-ehpbhi-p2-v2-0" }
      let(:status1) { Factory(:ncs_code, :list_name => "PPG_STATUS_CL1", :display_text => "PPG Group 1: Pregnant and Eligible", :local_code => 1) }
    
      it "creates a response set for the instrument with prepopulated answers" do
  
        pv1survey = Survey.find_by_access_code(access_code)
        if pv1survey.blank? 
          pv1survey = Factory(:survey, :title => "INS_QUE_PregVisit1_INT_EHPBHI_P2_V2.0", :access_code => access_code)
        end
  
        Factory(:ppg_status_history, :participant => participant, :ppg_status => status1)
  
        section   = Factory(:survey_section, :survey => pv1survey)
        question  = Factory(:question, :survey_section => section, :data_export_identifier => "name", :reference_identifier => "prepopulated_name")
        answer    = Factory(:answer, :question => question)
  
        ResponseSet.where(:user_id => person.id).should be_empty
      
        create_missing_in_error_ncs_codes(Instrument)
        instrument_type = Factory(:ncs_code, :list_name => 'INSTRUMENT_TYPE_CL1', :display_text => 'Pregnancy Visit 1 Interview')
        
        person.start_instrument(pv1survey)
      
        rs = ResponseSet.where(:user_id => person.id).first
        rs.should_not be_nil
        rs.responses.should_not be_empty
        rs.responses.first.string_value.should == person.name
      end
  
    end
    
  end
  
  
end
