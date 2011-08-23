require 'spec_helper'

describe ParticipantVisitConsent do
  
  it "creates a new instance given valid attributes" do
    pvc = Factory(:participant_visit_consent)
    pvc.should_not be_nil
  end
  
  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:contact) }
  it { should belong_to(:vis_person_who_consented) }
  
  it { should belong_to(:vis_who_consented) }
  it { should belong_to(:vis_consent_type) }
  it { should belong_to(:vis_consent_response) }
  it { should belong_to(:vis_language) }
  it { should belong_to(:vis_translate) }
  
  context "as mdes record" do
    
    it "sets the public_id to a uuid" do
      pvc = Factory(:participant_visit_consent)
      pvc.public_id.should_not be_nil
      pvc.pid_visit_consent_id.should == pvc.public_id
      pvc.pid_visit_consent_id.length.should == 36
    end
    
    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(ParticipantVisitConsent)
      
      pvc = ParticipantVisitConsent.new
      pvc.psu = Factory(:ncs_code)
      pvc.participant = Factory(:participant)
      pvc.vis_person_who_consented = Factory(:person)
      pvc.save!
    
      obj = ParticipantVisitConsent.find(pvc.id)
      obj.vis_consent_type.local_code.should == -4
      obj.vis_consent_response.local_code.should == -4
      obj.vis_language.local_code.should == -4
      obj.vis_who_consented.local_code.should == -4
      obj.vis_translate.local_code.should == -4
    end
  end
  
end
