# == Schema Information
# Schema version: 20120626221317
#
# Table name: non_interview_reports
#
#  id                             :integer         not null, primary key
#  psu_code                       :integer         not null
#  nir_id                         :string(36)      not null
#  contact_id                     :integer
#  nir                            :text
#  dwelling_unit_id               :integer
#  person_id                      :integer
#  nir_vacancy_information_code   :integer         not null
#  nir_vacancy_information_other  :string(255)
#  nir_no_access_code             :integer         not null
#  nir_no_access_other            :string(255)
#  nir_access_attempt_code        :integer         not null
#  nir_access_attempt_other       :string(255)
#  nir_type_person_code           :integer         not null
#  nir_type_person_other          :string(255)
#  cog_inform_relation_code       :integer         not null
#  cog_inform_relation_other      :string(255)
#  cog_disability_description     :text
#  permanent_disability_code      :integer         not null
#  deceased_inform_relation_code  :integer         not null
#  deceased_inform_relation_other :string(255)
#  year_of_death                  :integer
#  state_of_death_code            :integer         not null
#  who_refused_code               :integer         not null
#  who_refused_other              :string(255)
#  refuser_strength_code          :integer         not null
#  refusal_action_code            :integer         not null
#  long_term_illness_description  :text
#  permanent_long_term_code       :integer         not null
#  reason_unavailable_code        :integer         not null
#  reason_unavailable_other       :string(255)
#  date_available_date            :date
#  date_available                 :string(10)
#  date_moved_date                :date
#  date_moved                     :string(10)
#  moved_length_time              :decimal(6, 2)
#  moved_unit_code                :integer         not null
#  moved_inform_relation_code     :integer         not null
#  moved_inform_relation_other    :string(255)
#  nir_other                      :text
#  transaction_type               :string(36)
#  created_at                     :datetime
#  updated_at                     :datetime
#

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
