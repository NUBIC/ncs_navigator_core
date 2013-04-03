# == Schema Information
# Schema version: 20130329150304
#
# Table name: sampled_persons_ineligibilities
#
#  age_eligible_code         :integer
#  county_of_residence_code  :integer
#  created_at                :datetime
#  first_prenatal_visit_code :integer
#  id                        :integer          not null, primary key
#  ineligible_by_code        :integer
#  person_id                 :integer
#  pregnancy_eligible_code   :integer
#  provider_id               :integer
#  psu_code                  :integer          not null
#  sampled_persons_inelig_id :string(36)       not null
#  transaction_type          :string(36)
#  updated_at                :datetime
#

require 'spec_helper'

require File.expand_path('../../shared/custom_recruitment_strategy', __FILE__)

describe SampledPersonsIneligibility do

  it "should create_from_person! a new instance given valid attributes" do
    sam_per_inelig = Factory(:sampled_persons_ineligibility)
    sam_per_inelig.should_not be_nil
  end

  it { should belong_to(:person) }
  it { should belong_to(:provider) }


  context "as mdes record" do

    it "sets the public_id to a uuid" do
      sam_per_inelig = Factory(:sampled_persons_ineligibility)
      sam_per_inelig.public_id.should_not be_nil
      sam_per_inelig.sampled_persons_inelig_id.should == sam_per_inelig.public_id
      sam_per_inelig.sampled_persons_inelig_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      sam_per_inelig = SampledPersonsIneligibility.new
      sam_per_inelig.psu_code = 20000030
      sam_per_inelig.person = Factory(:person)
      sam_per_inelig.provider = Factory(:provider)
      sam_per_inelig.save!

      obj = SampledPersonsIneligibility.first
      obj.age_eligible.local_code.should == -4
      obj.county_of_residence.local_code.should == -4
      obj.first_prenatal_visit.local_code.should == -4
      obj.ineligible_by.local_code.should == -4
	  end
  end

  context "record creation" do
    include SurveyCompletion

    include_context 'custom recruitment strategy'

    let(:recruitment_strategy) { ProviderBasedSubsample.new }

    let(:yes)     { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL3", 1) }
    let(:no)     { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL3", 2) }
    let(:unknown) { NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL3", -6) }

    before do
      NcsNavigatorCore.stub!(:recruitment_type_id).and_return(5)
      @part = Factory(:participant)
      @pers = Factory(:person)
      @pers.participant = @part
      @survey = create_pbs_eligibility_screener_survey_with_eligibility_questions
      @response_set, instrument = prepare_instrument(@pers, @part, @survey)

      @age_eligible = NcsCode.for_list_name_and_local_code("AGE_ELIGIBLE_CL1", 1)
      @does_not_live_in_county = NcsCode.for_list_name_and_local_code("SCREENER_ELIG_PSU_CL1", 2)
      @first_visit = NcsCode.for_list_name_and_local_code("CONFIRM_TYPE_CL7", 1)
      @pregnant = NcsCode.for_list_name_and_local_code("PPG_STATUS_CL2", 1)

    end

    context "non-birth cohort" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.AGE_ELIG", @age_eligible
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PSU_ELIG_CONFIRM", @does_not_live_in_county
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.FIRST_VISIT", @first_visit
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::INTERVIEW_PREFIX}.PREGNANT", @pregnant
        end
      end

      it "create_from_person!s a record" do
        SampledPersonsIneligibility.create_from_person!(@pers)
        SampledPersonsIneligibility.count.should == 1
      end

      it "populates correctly" do
        spi = SampledPersonsIneligibility.create_from_person!(@pers)
        spi.age_eligible.should == yes
        spi.county_of_residence.should == no
        spi.first_prenatal_visit.should == yes
        spi.pregnancy_eligible.should == yes
      end
    end

    context "birth cohort" do
      before do
        take_survey(@survey, @response_set) do |r|
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.AGE_ELIG", @age_eligible
          r.a "#{OperationalDataExtractor::PbsEligibilityScreener::HOSPITAL_INTERVIEW_PREFIX}.PSU_ELIG_CONFIRM", @does_not_live_in_county
        end
        @part.stub(:birth_cohort? => true)
        @part.stub(:hospital? => true)
      end

      it "create_from_person's a record" do
        SampledPersonsIneligibility.create_from_person!(@pers)
        SampledPersonsIneligibility.count.should == 1
      end

      it "populates correctly" do
        birth_cohort_spi = SampledPersonsIneligibility.create_from_person!(@pers)
        birth_cohort_spi.age_eligible.should == yes
        birth_cohort_spi.county_of_residence.should == no
        birth_cohort_spi.first_prenatal_visit.should == unknown
        birth_cohort_spi.pregnancy_eligible.should == unknown
      end
    end
  end
end
