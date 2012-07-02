# -*- coding: utf-8 -*-


require 'spec_helper'

describe NonInterviewReport do
  it "should create a new instance given valid attributes" do
    nir = Factory(:non_interview_report)
    nir.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:nir_vacancy_information) }
  it { should belong_to(:nir_no_access) }
  it { should belong_to(:nir_access_attempt) }
  it { should belong_to(:nir_type_person) }
  it { should belong_to(:cog_inform_relation) }
  it { should belong_to(:permanent_disability) }
  it { should belong_to(:deceased_inform_relation) }
  it { should belong_to(:state_of_death) }
  it { should belong_to(:who_refused) }
  it { should belong_to(:refuser_strength) }
  it { should belong_to(:refusal_action) }
  it { should belong_to(:permanent_long_term) }
  it { should belong_to(:reason_unavailable) }
  it { should belong_to(:moved_unit) }
  it { should belong_to(:moved_inform_relation) }

  it { should have_many(:vacant_non_interview_reports) }
  it { should have_many(:no_access_non_interview_reports) }
  it { should have_many(:refusal_non_interview_reports) }
  it { should have_many(:dwelling_unit_type_non_interview_reports) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      nir = Factory(:non_interview_report)
      nir.public_id.should_not be_nil
      nir.nir_id.should == nir.public_id
      nir.nir_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      nir = NonInterviewReport.new
      nir.save!

      obj = NonInterviewReport.first
      obj.nir_vacancy_information.local_code.should == -4
      obj.nir_no_access.local_code.should == -4
      obj.nir_access_attempt.local_code.should == -4
      obj.nir_type_person.local_code.should == -4
      obj.cog_inform_relation.local_code.should == -4
      obj.permanent_disability.local_code.should == -4
      obj.deceased_inform_relation.local_code.should == -4
      obj.state_of_death.local_code.should == -4
      obj.who_refused.local_code.should == -4
      obj.refuser_strength.local_code.should == -4
      obj.refusal_action.local_code.should == -4
      obj.permanent_long_term.local_code.should == -4
      obj.reason_unavailable.local_code.should == -4
      obj.moved_unit.local_code.should == -4
      obj.moved_inform_relation.local_code.should == -4

    end
  end
end

