# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: non_interview_reports
#
#  cog_disability_description     :text
#  cog_inform_relation_code       :integer          not null
#  cog_inform_relation_other      :string(255)
#  contact_id                     :integer
#  created_at                     :datetime
#  date_available                 :string(10)
#  date_available_date            :date
#  date_moved                     :string(10)
#  date_moved_date                :date
#  deceased_inform_relation_code  :integer          not null
#  deceased_inform_relation_other :string(255)
#  dwelling_unit_id               :integer
#  id                             :integer          not null, primary key
#  long_term_illness_description  :text
#  moved_inform_relation_code     :integer          not null
#  moved_inform_relation_other    :string(255)
#  moved_length_time              :decimal(6, 2)
#  moved_unit_code                :integer          not null
#  nir                            :text
#  nir_access_attempt_code        :integer          not null
#  nir_access_attempt_other       :string(255)
#  nir_id                         :string(36)       not null
#  nir_no_access_code             :integer          not null
#  nir_no_access_other            :string(255)
#  nir_other                      :text
#  nir_type_person_code           :integer          not null
#  nir_type_person_other          :string(255)
#  nir_vacancy_information_code   :integer          not null
#  nir_vacancy_information_other  :string(255)
#  permanent_disability_code      :integer          not null
#  permanent_long_term_code       :integer          not null
#  person_id                      :integer
#  psu_code                       :integer          not null
#  reason_unavailable_code        :integer          not null
#  reason_unavailable_other       :string(255)
#  refusal_action_code            :integer          not null
#  refuser_strength_code          :integer          not null
#  state_of_death_code            :integer          not null
#  transaction_type               :string(36)
#  updated_at                     :datetime
#  who_refused_code               :integer          not null
#  who_refused_other              :string(255)
#  year_of_death                  :integer
#



require 'spec_helper'

describe NonInterviewReport do
  it "should create a new instance given valid attributes" do
    nir = Factory(:non_interview_report)
    nir.should_not be_nil
  end


  it { should have_many(:vacant_non_interview_reports) }
  it { should have_many(:no_access_non_interview_reports) }
  it { should have_many(:refusal_non_interview_reports) }
  it { should have_many(:dwelling_unit_type_non_interview_reports) }

  it { should have_one(:response_set) }

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

  describe ".start!" do
    let(:contact) { Factory(:contact) }
    let(:person) { Factory(:person) }
    let(:participant) { Factory(:participant) }
    let(:survey) { Survey.last }

    describe "for a new NonInterviewReport record" do

      before do
        f = "#{Rails.root}/internal_surveys/IRB_CON_NonInterviewReport.rb"
        Surveyor::Parser.parse File.read(f)

        NonInterviewReport.count.should == 0
        NonInterviewReport.start!(person, participant, survey, contact)
      end

      it "creates a new NonInterviewReport record" do
        NonInterviewReport.count.should == 1
        nir = NonInterviewReport.first
        nir.contact.should == contact
        nir.response_set.survey.should == survey
        nir.response_set.participant.should == participant
        nir.response_set.person.should == person
        nir.person.should == person
      end

      it "creates an associated ResponseSet" do
        NonInterviewReport.first.response_set.should_not be_nil
      end
    end

    describe "for a existing NonInterviewReport record" do

      before do
        f = "#{Rails.root}/internal_surveys/IRB_CON_Informed_Consent.rb"
        Surveyor::Parser.parse File.read(f)
      end

      it "returns the NonInterviewReport associated with the survey, person, and contact" do
        2.times do |i|
          NonInterviewReport.count.should == i
          NonInterviewReport.start!(person, participant, survey, contact)
          NonInterviewReport.count.should == 1
        end

        nir = NonInterviewReport.last
        nir.contact.should == contact
        nir.response_set.survey.should == survey
        nir.response_set.participant.should == participant
        nir.response_set.person.should == person
        nir.person.should == person
      end

    end
  end

end

