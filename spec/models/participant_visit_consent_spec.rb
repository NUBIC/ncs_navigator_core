# == Schema Information
# Schema version: 20120626221317
#
# Table name: participant_visit_consents
#
#  id                          :integer         not null, primary key
#  psu_code                    :integer         not null
#  pid_visit_consent_id        :string(36)      not null
#  participant_id              :integer
#  vis_consent_type_code       :integer         not null
#  vis_consent_response_code   :integer         not null
#  vis_language_code           :integer         not null
#  vis_language_other          :string(255)
#  vis_person_who_consented_id :integer
#  vis_who_consented_code      :integer         not null
#  vis_translate_code          :integer         not null
#  vis_comments                :text
#  contact_id                  :integer
#  transaction_type            :string(36)
#  created_at                  :datetime
#  updated_at                  :datetime
#

# -*- coding: utf-8 -*-

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

  context ".visit_types" do

    it "returns an id, label list of potential visit types" do
      vts = ParticipantVisitConsent.visit_types
      vts.length.should == 6
      vts.first.should == ["1", "Interviewer-Administered Questionnaire"]
    end

  end

  context ".event_types_with_visit_information_sheets" do

    it "returns the known event type code values for events where a VIS is presented" do
      vis_events = ParticipantVisitConsent.event_types_with_visit_information_sheets
      vis_events.size.should == 8
      vis_events.should == ['11', '13', '15', '18', '19', '24', '27', '33']
    end

  end

  context ".visit_information_sheet_presented?" do

    describe "nil" do
      it "simply returns false" do
        ParticipantVisitConsent.visit_information_sheet_presented?(nil).should be_false
      end

    end

    describe "Pregnancy Screener Event (29)" do
      it "is false" do
        event = Factory(:event, :event_type_code => 29)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_false
      end
    end

    describe "Pregnancy Probability (7)" do
      it "is false" do
        event = Factory(:event, :event_type_code => 7)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_false
      end
    end

    describe "Informed Consent (10)" do
      it "is false" do
        event = Factory(:event, :event_type_code => 10)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_false
      end
    end

    describe "Pre-Pregnancy Event (11)" do
      it "is true" do
        event = Factory(:event, :event_type_code => 11)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_true
      end
    end

    describe "Pregnancy Visit 1 Event (13)" do
      it "is true" do
        event = Factory(:event, :event_type_code => 13)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_true
      end
    end

    describe "Pregnancy Visit 2 Event (15)" do
      it "is true" do
        event = Factory(:event, :event_type_code => 15)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_true
      end
    end

    describe "Birth Event (18)" do
      it "is true" do
        event = Factory(:event, :event_type_code => 18)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_true
      end
    end

    describe "Father Event (19)" do
      it "is true" do
        event = Factory(:event, :event_type_code => 19)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_true
      end
    end

    describe "3 Month Event (23)" do
      it "is false" do
        event = Factory(:event, :event_type_code => 23)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_false
      end
    end

    describe "6 Month Event (24)" do
      it "is true" do
        event = Factory(:event, :event_type_code => 24)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_true
      end
    end

    describe "9 Month Event (26)" do
      it "is false" do
        event = Factory(:event, :event_type_code => 26)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_false
      end
    end

    describe "12 Month Event (27)" do
      it "is true" do
        event = Factory(:event, :event_type_code => 27)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_true
      end
    end

    describe "18 Month Event (30)" do
      it "is false" do
        event = Factory(:event, :event_type_code => 30)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_false
      end
    end

    describe "24 Month Event (31)" do
      it "is false" do
        event = Factory(:event, :event_type_code => 31)
        ParticipantVisitConsent.visit_information_sheet_presented?(event).should be_false
      end
    end


  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pvc = Factory(:participant_visit_consent)
      pvc.public_id.should_not be_nil
      pvc.pid_visit_consent_id.should == pvc.public_id
      pvc.pid_visit_consent_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      pvc = ParticipantVisitConsent.new
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
