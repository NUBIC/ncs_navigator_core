# -*- coding: utf-8 -*-

# == Schema Information
# Schema version: 20120426034324
#
# Table name: participant_visit_records
#
#  id                        :integer         not null, primary key
#  psu_code                  :integer         not null
#  rvis_id                   :string(36)      not null
#  participant_id            :integer
#  rvis_language_code        :integer         not null
#  rvis_language_other       :string(255)
#  rvis_person_id            :integer
#  rvis_who_consented_code   :integer         not null
#  rvis_translate_code       :integer         not null
#  contact_id                :integer
#  time_stamp_1              :datetime
#  time_stamp_2              :datetime
#  rvis_sections_code        :integer         not null
#  rvis_during_interv_code   :integer         not null
#  rvis_during_bio_code      :integer         not null
#  rvis_bio_cord_code        :integer         not null
#  rvis_during_env_code      :integer         not null
#  rvis_during_thanks_code   :integer         not null
#  rvis_after_saq_code       :integer         not null
#  rvis_reconsideration_code :integer         not null
#  transaction_type          :string(36)
#  created_at                :datetime
#  updated_at                :datetime
#

require 'spec_helper'

describe ParticipantVisitRecord do
  it "creates a new instance given valid attributes" do
    pvr = Factory(:participant_visit_record)
    pvr.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:participant) }
  it { should belong_to(:rvis_person) }

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
      create_missing_in_error_ncs_codes(ParticipantVisitRecord)

      pvr = ParticipantVisitRecord.new
      pvr.psu = Factory(:ncs_code)
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
