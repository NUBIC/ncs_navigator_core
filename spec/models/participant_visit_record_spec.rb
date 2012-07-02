# -*- coding: utf-8 -*-


require 'spec_helper'

describe ParticipantVisitRecord do
  it "creates a new instance given valid attributes" do
    pvr = Factory(:participant_visit_record)
    pvr.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:rvis_person) }
  it { should belong_to(:contact) }

  it { should belong_to(:rvis_who_consented) }

  it { should belong_to(:rvis_language) }
  it { should belong_to(:rvis_translate) }
  it { should belong_to(:rvis_sections) }
  it { should belong_to(:rvis_during_interv) }
  it { should belong_to(:rvis_during_bio) }
  it { should belong_to(:rvis_bio_cord) }
  it { should belong_to(:rvis_during_env) }
  it { should belong_to(:rvis_during_thanks) }
  it { should belong_to(:rvis_after_saq) }
  it { should belong_to(:rvis_reconsideration) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pvr = Factory(:participant_visit_record)
      pvr.public_id.should_not be_nil
      pvr.rvis_id.should == pvr.public_id
      pvr.rvis_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      pvr = ParticipantVisitRecord.new
      pvr.participant = Factory(:participant)
      pvr.rvis_person = Factory(:person)
      pvr.contact = Factory(:contact)
      pvr.save!

      obj = ParticipantVisitRecord.find(pvr.id)
      obj.rvis_language.local_code.should == -4
      obj.rvis_who_consented.local_code.should == -4
      obj.rvis_translate.local_code.should == -4
      obj.rvis_sections.local_code.should == -4
      obj.rvis_during_interv.local_code.should == -4
      obj.rvis_during_bio.local_code.should == -4
      obj.rvis_bio_cord.local_code.should == -4
      obj.rvis_during_env.local_code.should == -4
      obj.rvis_during_thanks.local_code.should == -4
      obj.rvis_after_saq.local_code.should == -4
      obj.rvis_reconsideration.local_code.should == -4
    end
  end
end

