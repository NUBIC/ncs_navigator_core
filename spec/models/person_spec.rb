# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: people
#
#  age                            :integer
#  age_range_code                 :integer          not null
#  being_processed                :boolean          default(FALSE)
#  created_at                     :datetime
#  date_move                      :string(7)
#  date_move_date                 :date
#  deceased_code                  :integer          not null
#  ethnic_group_code              :integer          not null
#  first_name                     :string(30)
#  id                             :integer          not null, primary key
#  language_code                  :integer          not null
#  language_new_code              :integer
#  language_new_other             :string(255)
#  language_other                 :string(255)
#  last_name                      :string(30)
#  lock_version                   :integer          default(0)
#  maiden_name                    :string(30)
#  marital_status_code            :integer          not null
#  marital_status_other           :string(255)
#  middle_name                    :string(30)
#  move_info_code                 :integer          not null
#  p_info_date                    :date
#  p_info_source_code             :integer          not null
#  p_info_source_other            :string(255)
#  p_info_update                  :date
#  p_tracing_code                 :integer          not null
#  person_comment                 :text
#  person_dob                     :string(10)
#  person_dob_date                :date
#  person_id                      :string(36)       not null
#  planned_move_code              :integer          not null
#  preferred_contact_method_code  :integer          not null
#  preferred_contact_method_other :string(255)
#  prefix_code                    :integer          not null
#  psu_code                       :integer          not null
#  response_set_id                :integer
#  role                           :string(255)
#  sex_code                       :integer          not null
#  suffix_code                    :integer          not null
#  title                          :string(5)
#  transaction_type               :string(36)
#  updated_at                     :datetime
#  when_move_code                 :integer          not null
#



require 'spec_helper'

describe Person do
  before(:each) do
    @y = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)
    @n = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
    @q = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', -4)
  end

  it "creates a new instance given valid attributes" do
    pers = Factory(:person)
    pers.should_not be_nil
  end

  describe ".full_name" do
    it "returns first and last name" do
      pers = Factory(:person)
      name = "#{pers.first_name} #{pers.last_name}"
      pers.to_s.should == name
      pers.name.should == name
      pers.full_name.should == name
    end
  end


  # it { should validate_presence_of(:first_name) }
  # it { should validate_presence_of(:last_name) }

  it { should belong_to(:response_set) }
  it { should have_many(:response_sets) }
  it { should have_many(:contact_links) }
  it { should have_many(:events).through(:contact_links) }
  it { should have_many(:participant_person_links) }
  it { should have_many(:participants).through(:participant_person_links) }
  it { should have_many(:institution_person_links) }
  it { should have_many(:institutions).through(:institution_person_links) }

  it { should have_many(:person_provider_links) }
  it { should have_many(:providers).through(:person_provider_links) }

  it { should have_many(:household_person_links) }
  it { should have_many(:household_units).through(:household_person_links) }

  it { should have_many(:addresses) }
  it { should have_many(:telephones) }
  it { should have_many(:emails) }
  it { should have_many(:races) }
  it { should have_many(:non_interview_reports) }

  it { should ensure_length_of(:person_dob).is_equal_to(10) }
  it { should ensure_length_of(:date_move).is_equal_to(7) }
  it { should ensure_length_of(:title).is_at_most(5) }
  it { should ensure_length_of(:first_name).is_at_most(30) }
  it { should ensure_length_of(:last_name).is_at_most(30) }
  it { should ensure_length_of(:maiden_name).is_at_most(30) }
  it { should ensure_length_of(:middle_name).is_at_most(30) }

  context "as mdes record" do

    describe 'the public ID' do
      let(:person) { Factory(:person) }

      it 'is a human-readable ID with 12 ID chars' do
        person.public_id.should =~ /^\w{4}-\w{4}-\w{4}$/
      end

      it 'is named person_id' do
        person.public_id.should == person.person_id
      end
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      pers = Person.new
      pers.first_name = "John"
      pers.last_name = "Doe"
      pers.save!

      obj = Person.find(pers.id)
      obj.prefix.local_code.should == -4
      obj.suffix.local_code.should == -4
      obj.sex.local_code.should == -4
      obj.age_range.local_code.should == -4
      obj.deceased.local_code.should == -4
      obj.ethnic_group.local_code.should == -4
      obj.language.local_code.should == -4
      obj.language_new.local_code.should == -4
      obj.marital_status.local_code.should == -4
      obj.preferred_contact_method.local_code.should == -4
      obj.planned_move.local_code.should == -4
      obj.move_info.local_code.should == -4
      obj.when_move.local_code.should == -4
      obj.p_tracing.local_code.should == -4
      obj.p_info_source.local_code.should == -4
    end
  end

  context "relationship between person and participant" do

    describe "#participant=" do

      let(:participant) { Factory(:participant) }
      let(:person) { Factory(:person) }

      describe "without an existing relationship" do
        before do
          person.participant.should be_nil
          person.participant_person_links.should be_empty

          person.participant = participant
        end

        it "creates the relationship" do
          person.participant_person_links.first.relationship_code.should == 1
        end

        it "associates to the correct participant" do
          person.participant_person_links.first.participant.should == participant
        end

      end

      describe "with an existing relationship" do
        let!(:existing_link) {
          person.participant_person_links.create(
            :relationship_code => 1, :psu => person.psu, :participant => Factory(:participant, :p_id => "asdf"))
        }

        before do
          person.participant = participant
        end

        it "does not add another link" do
          person.should have(1).participant_person_link
        end

        it "updates the associated participant" do
          person.participant.should == participant
        end
      end
    end

  end

  context "mdes date formatting" do

    it "sets the corresponding date field with the user entered date" do
      dob = Date.today
      pers = Factory(:person)
      pers.person_dob_date = dob
      pers.save!
      pers = Person.last
      pers.person_dob.should == Date.today.strftime('%Y-%m-%d')
    end

    it "sets the person_dob if the person has refused to give the information" do
      pers = Factory(:person)
      pers.person_dob_modifier = "refused"
      pers.save!

      pers = Person.last
      pers.person_dob.should == '9111-91-91'
    end

    it "sets the person_dob if the person said the information is unknown" do
      pers = Factory(:person)
      pers.person_dob_modifier = "unknown"
      pers.save!

      pers = Person.last
      pers.person_dob.should == '9666-96-96'
    end

    it "sets the corresponding date field with the user entered date properly formatted" do
      move_date = Date.today
      pers = Factory(:person)
      pers.date_move_date = move_date
      pers.save!
      pers = Person.last
      pers.date_move.should == Date.today.strftime('%Y-%m')
    end

    it "sets the date_move if the person said the information is not_applicable" do
      pers = Factory(:person)
      pers.date_move_modifier = "not_applicable"
      pers.save!

      pers = Person.last
      pers.date_move.should == '9777-97'
    end

    it "clears person_dob_date if person_dob is not a date" do
      pers = Factory(:person, :person_dob => '1998-05-01')
      pers.person_dob_date.should == Date.parse('1998-05-01')
      pers.person_dob_modifier = "refused"
      pers.save!

      pers = Person.last
      pers.person_dob.should == '9111-91-91'
      pers.person_dob_date.should == nil
    end
  end

  describe "#computed_age" do

    it "returns the person's age" do
      pers = Factory(:person, :person_dob_date => 10.years.ago, :age => nil)
      pers.age.should == 10
      pers.computed_age.should == 10
    end

    it "does not blowup on leap year" do
      dob = Date.parse('1992-02-29')
      pers = Factory(:person, :person_dob_date => dob)
      (pers.computed_age > 18).should be_true
    end

    it "does not return anything if person dob is unknown" do
      pers = Factory(:person)
      pers.person_dob_modifier = "unknown"
      pers.save!

      Person.last.computed_age.should be_nil
    end

    it "does not return anything if person dob is refused" do
      pers = Factory(:person)
      pers.person_dob_modifier = "refused"
      pers.save!

      Person.last.computed_age.should be_nil
    end

    it "handles a string date" do
      dob = 10.years.ago
      pers = Factory(:person, :person_dob_date => nil, :person_dob => dob.strftime('%Y-%m-%d'))
      pers.computed_age.should == 10
    end

    %w(
      9111-91-91
      9666-96-96
      9777-97-97
      1980-91-91
      1963-07-91
    ).each do |n|
      it "handles a string unknown date of type #{n}" do
        pers = Factory(:person, :person_dob_date => nil, :person_dob => n)
        pers.save!
        pers.computed_age.should be_nil
      end
    end
  end

  describe "#computed_age_range" do
    it "returns nil if person_dob_date is nil" do
      p=Factory(:person, :person_dob => nil)
      p[:person_dob_date].should == nil
      p.computed_age_range.should == nil

      p1=Factory(:person, :person_dob=>"9666-96-96")
      p1[:person_dob_date].should == nil
      p1.computed_age_range.should == nil
    end

    it "returns codes for AGE_RANGE_CL1" do
      [[3.months, 1],
      [3.years,   1],
      [25.years,  3],
      [64.years,  6],
      [100.years, 7]].each do |(time, code)|
        Person.new(:person_dob=>time.ago.to_date.to_s).computed_age_range.should == code
      end
    end

    it "returns display text for AGE_RANGE_CL1" do
      [[3.months, 'Less than 18'],
      [3.years,   'Less than 18'],
      [25.years,  '25-34'],
      [64.years,  '50-64'],
      [100.years, '65+']].each do |(time, text)|
        Person.new(:person_dob=>time.ago.to_date.to_s).computed_age_range(true).should == text
      end
    end
  end

  context "with events and assigned to a PPG" do

    describe "a person who is not a participant" do

      it "knows the upcoming applicable events" do
        pers = Factory(:person)
        pers.upcoming_events.should_not be_empty

        pers.should_not be_participant
        pers.upcoming_events.should == ["Pregnancy Screener"]
      end
    end

  end

  context "with a response set" do

    before(:each) do
      @pers = Factory(:person)
      @part = Factory(:participant)
      @survey = create_test_survey_for_person
      @rs, @instrument = prepare_instrument(@pers, @part, @survey)
    end

    it "knows the last incomplete response set" do
      @rs.save!

      pers = Person.find(@pers.id)
      pers.response_sets.size.should == 1
      pers.response_sets.last.should == @rs
      pers.last_incomplete_response_set.should == @rs
      pers.last_incomplete_response_set.should_not be_complete

      @rs.complete!
      @rs.save!
      pers = Person.find(@pers.id)
      pers.last_incomplete_response_set.should be_nil

    end

    it "knows the last completed survey" do
      @rs.complete!
      @rs.save!
      pers = Person.find(@pers.id)
      pers.last_completed_survey.should == @survey
    end

    it "knows the last incomplete survey"

  end

  context "responses to instrument questions" do

    before(:each) do
    end

    it "should get responses by data_export_identifier" do
      person = Factory(:person)
      participant = Factory(:participant)

      survey = create_pregnancy_screener_survey_with_cell_phone_permissions
      survey_section = survey.sections.first
      response_set, instrument = prepare_instrument(person, participant, survey)

      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.CELL_PHONE_2"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.CELL_PHONE_4"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      person  = Person.find(person.id)
      can_use_phone_to_setup_appts = person.responses_for("#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.CELL_PHONE_2")
      can_use_phone_to_setup_appts.size.should == 1
      can_use_phone_to_setup_appts.first.to_s.should == "Yes"

      can_text_to_setup_appts = person.responses_for("#{OperationalDataExtractor::PregnancyScreener::INTERVIEW_PREFIX}.CELL_PHONE_4")
      can_text_to_setup_appts.size.should == 1
      can_text_to_setup_appts.first.to_s.should == "Yes"
    end

    context "repeating the instrument" do

      before(:each) do
        @person = Factory(:person)
        @participant = Factory(:participant)
        @survey = create_test_survey_for_person
      end

      it "returns 0 for the instrument_repeat_key if this is the first time taking the instrument" do
        response_set, instrument = prepare_instrument(@person, @participant, @survey)
        @person.instrument_repeat_key(instrument.survey).should == 0
      end

      it "returns 1 for the instrument_repeat_key if this is the second time taking the instrument" do
        response_set0, instrument0 = prepare_instrument(@person, @participant, @survey)
        response_set1, instrument1 = prepare_instrument(@person, @participant, @survey)
        response_set0.save!
        response_set1.save!

        @person.reload.instrument_repeat_key(instrument1.survey).should == 1
      end

    end

    context "setting default instrument values" do

      before(:each) do
        @person = Factory(:person)
        @survey = create_test_survey_for_person
        @participant = Factory(:participant)
      end

      it "should set the supervisor_review_code" do
        response_set, instrument = prepare_instrument(@person, @participant, @survey)
        instrument.supervisor_review.should == @n
      end

      it "should set the data_problem_code" do
        response_set, instrument = prepare_instrument(@person, @participant, @survey)
        instrument.data_problem.should == @n
      end

      it "should set the instrument_mode_code" do
        telephone_computer_administered = NcsCode.for_list_name_and_local_code('INSTRUMENT_ADMIN_MODE_CL1', Instrument.cati)
        response_set, instrument = prepare_instrument(@person, @participant, @survey, Instrument.cati)
        instrument.instrument_mode.should == telephone_computer_administered
      end

      it "should set the instrument_method_code" do
        interviewer_administered = NcsCode.for_list_name_and_local_code('INSTRUMENT_ADMIN_METHOD_CL1', 2)
        response_set, instrument = prepare_instrument(@person, @participant, @survey)
        instrument.instrument_method.should == interviewer_administered
      end

      it "should set the instrument_breakoff_code"

      it "should set the instrument_status_code"

      it "should set the instrument_repeat_key" do
        response_set, instrument = prepare_instrument(@person, @participant, @survey)
        instrument.instrument_repeat_key.should == 0
      end

    end

  end

  context "determining ssu and tsu" do

    let(:person) { Factory(:person) }
    let(:du) { Factory(:dwelling_unit) }
    let(:du2) { Factory(:dwelling_unit) }
    let(:hu) { Factory(:household_unit) }

    describe "#dwelling_units" do
      describe "without associated addresses or household_units" do
        it "is empty when the person addresses and household_units associations are empty" do
          person.addresses.should be_empty
          person.dwelling_units.should be_empty
        end
      end

      describe "with associated addresses but no household_unit association" do
        it "returns the person addresses dwelling_unit associations" do
          person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
          person.dwelling_units.should == [du]
        end
      end

      describe "with associated household units but no address association" do
        it "returns the person household_units dwelling_unit associations" do
          Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
          Factory(:household_person_link, :person => person, :household_unit => hu)
          person.household_units.reload
          person.addresses.should be_empty
          person.dwelling_units.should == [du]
        end
      end

      describe "with household units and addresses associations" do
        it "returns the all uniq dwelling_unit associations" do
          Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
          Factory(:household_person_link, :person => person, :household_unit => hu)
          person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
          person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          person.dwelling_units.should == [du, du2]
        end
      end
    end

    describe "#ssu_ids" do
      describe "with household units and addresses associations" do

        describe "and both of the dwelling units has a ssu_id" do
          before do
            du.update_attribute(:ssu_id, "ssu_id")
            du2.update_attribute(:ssu_id, "ssu_id2")
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "returns all tsu_ids" do
            person.ssu_ids.should == ["ssu_id", "ssu_id2"]
          end
        end

        describe "and both of the dwelling units have the same ssu_id" do
          before do
            du.update_attribute(:ssu_id, "ssu_id")
            du2.update_attribute(:ssu_id, "ssu_id")
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "returns the uniq ssu_id" do
            person.ssu_ids.should == ["ssu_id"]
          end
        end
      end
    end

    describe "#tsu_ids" do
      describe "with household units and addresses associations" do

        describe "and none of the dwelling unit has a tsu_id" do
          before do
            du.tsu_id.should be_nil
            du2.tsu_id.should be_nil
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "returns an empty collection" do
            person.tsu_ids.should be_empty
          end
        end

        describe "and one of the dwelling units has a tsu_id" do
          before do
            du.tsu_id.should be_nil
            du2.update_attribute(:tsu_id, "tsu_id")
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "returns the one tsu_id" do
            person.tsu_ids.should == ["tsu_id"]
          end
        end

        describe "and both of the dwelling units has a tsu_id" do
          before do
            du.update_attribute(:tsu_id, "tsu_id")
            du2.update_attribute(:tsu_id, "tsu_id2")
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "returns all tsu_ids" do
            person.tsu_ids.should == ["tsu_id", "tsu_id2"]
          end
        end

        describe "and both of the dwelling units have the same tsu_id" do
          before do
            du.update_attribute(:tsu_id, "tsu_id")
            du2.update_attribute(:tsu_id, "tsu_id")
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "returns the uniq tsu_id" do
            person.tsu_ids.should == ["tsu_id"]
          end
        end
      end
    end

    describe "#in_tsu?" do

      describe "without associated addresses or household_units" do
        before do
          person.addresses.should be_empty
          person.household_units.should be_empty
        end

        it "is not in a tsu" do
          person.should_not be_in_tsu
        end
      end

      describe "with associated addresses but no household_unit association" do

        describe "and the dwelling unit has a tsu_id" do
          before do
            du.update_attribute(:tsu_id, "tsu_id")
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.household_units.should be_empty
          end

          it "is in a tsu" do
            person.should be_in_tsu
          end
        end

        describe "and the dwelling unit does not have a tsu_id" do
          before do
            du.tsu_id.should be_nil
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.household_units.should be_empty
          end

          it "is not in a tsu" do
            person.should_not be_in_tsu
          end
        end

      end

      describe "with associated household units but no address association" do

        describe "and the dwelling unit has a tsu_id" do
          before do
            du.update_attribute(:tsu_id, "tsu_id")
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)

            person.addresses.should be_empty
          end

          it "is in a tsu" do
            person.should be_in_tsu
          end
        end

        describe "and the dwelling unit does not have a tsu_id" do
          before do
            du.tsu_id.should be_nil
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)

            person.addresses.should be_empty
          end

          it "is not in a tsu" do
            person.should_not be_in_tsu
          end
        end

      end

      describe "with household units and addresses associations" do

        describe "and one of the dwelling units has a tsu_id" do

          before do
            du.tsu_id.should be_nil
            du2.update_attribute(:tsu_id, "tsu_id")
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "is in a tsu" do
            person.should be_in_tsu
          end
        end

        describe "and none of the dwelling units has a tsu_id" do
          before do
            du.tsu_id.should be_nil
            du2.tsu_id.should be_nil
            Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hu)
            Factory(:household_person_link, :person => person, :household_unit => hu)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du)
            person.addresses << Factory(:address, :person => person, :dwelling_unit => du2)
          end

          it "is not in a tsu" do
            person.should_not be_in_tsu
          end
        end
      end
    end
  end

  describe 'phone number helpers' do
    let!(:primary) { NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 1) }
    let!(:person) { Factory(:person) }

    describe '#primary_cell_phone' do
      let!(:cell) { NcsCode.for_list_name_and_local_code('PHONE_TYPE_CL1', 3) }
      let!(:phone) { Factory(:telephone, :phone_rank => primary, :phone_type => cell, :person => person) }

      it 'returns the primary cell phone for the person' do
        person.primary_cell_phone.should == phone
      end

      it 'returns nil if no such phone number exists' do
        phone.destroy

        person.primary_cell_phone.should be_nil
      end
    end

    describe '#primary_home_phone' do
      let!(:home) { NcsCode.for_list_name_and_local_code('PHONE_TYPE_CL1', 1) }
      let!(:phone) { Factory(:telephone, :phone_rank => primary, :phone_type => home, :person => person) }

      it 'returns the primary home phone for the person' do
        person.primary_home_phone.should == phone
      end

      it 'returns nil if no such phone number exists' do
        phone.destroy

        person.primary_home_phone.should be_nil
      end
    end
  end

  describe ".first_child?" do

    let(:grandmother) { Factory(:person) }
    let(:mother) { Factory(:person) }
    let(:first_child) { Factory(:person) }
    let(:second_child) { Factory(:person) }
    let(:participant) { Factory(:participant) }

    before(:each) do
      # the mother participant has a mother relationship
      Factory(:participant_person_link, :participant => participant, :person => grandmother, :relationship_code => 2)
      participant.mother.should == grandmother

      participant.person = mother
      participant.save!
    end

    it "is false if the person is not a child" do
      mother.should_not be_first_child
    end

    describe "with one child" do

      before(:each) do
        child_participant = Factory(:participant)
        child_participant.person = first_child
        child_participant.save!

        ParticipantPersonLink.create(:person_id => first_child.id, :participant_id => participant.id, :relationship_code => 8) # 8 Child
        ParticipantPersonLink.create(:person_id => mother.id, :participant_id => child_participant.id, :relationship_code => 2) # 2 Mother
      end

      it "is true if the child is an only child" do
        first_child.mother.should_not be_nil
        first_child.mother.should == mother
        mother.children.size.should == 1

        first_child.should be_first_child
      end

      describe "and a subsequent child" do

        before(:each) do
          second_child_participant = Factory(:participant)
          second_child_participant.person = second_child
          second_child_participant.save!

          ParticipantPersonLink.create(:person_id => second_child.id, :participant_id => participant.id, :relationship_code => 8) # 8 Child
          ParticipantPersonLink.create(:person_id => mother.id, :participant_id => second_child_participant.id, :relationship_code => 2) # 2 Mother
        end

        it "is true if the child is the first child of many" do
          first_child.mother.should_not be_nil
          first_child.mother.should == mother
          second_child.mother.should_not be_nil
          second_child.mother.should == mother
          mother.children.size.should == 2

          first_child.should be_first_child
        end

        it "is false if the child is NOT the first child of many" do
          first_child.mother.should_not be_nil
          first_child.mother.should == mother
          second_child.mother.should_not be_nil
          second_child.mother.should == mother
          mother.children.size.should == 2

          first_child.should be_first_child
        end
      end
    end
  end

  describe 'contact information helpers' do
    let!(:primary) { NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 1) }
    let!(:address) { Factory(:address, :address_rank_code => primary.to_i, :person => person) }
    let!(:email) { Factory(:email, :email_rank_code => primary.to_i, :person => person) }
    let!(:person) { Factory(:person) }

    describe '#primary_address' do
      it 'returns the primary address for the person' do
        person.primary_address.should == address
      end

      it 'returns nil if no such address exists' do
        address.destroy

        person.primary_address.should be_nil
      end
    end

    describe '#primary_email' do
      it 'returns the primary email for the person' do
        person.primary_email.should == email
      end

      it 'returns nil if no such email exists' do
        email.destroy

        person.primary_email.should be_nil
      end
    end
  end

  describe ".relationship_to_person_via_participant" do
    let(:mother) { Factory(:person) }
    let(:child) { Factory(:person) }
    let(:participant) { Factory(:participant) }
    let(:participant2) { Factory(:participant) }
    let(:stranger1) { Factory(:person) }
    let(:stranger2) { Factory(:person) }

    before(:each) do
      Factory(:participant_person_link,
              :participant => participant,
              :person => mother,
              :relationship_code => 2
             )
      participant.person = child
      participant.save!

      Factory(:participant_person_link,
              :participant => participant2,
              :person => stranger1,
              :relationship_code => 1)
      participant2.person = stranger1
      participant2.save!
    end

    it "finds that child's mother is Biological Mother" do
      rel = child.relationship_to_person_via_participant(mother)
      rel.should == 'Biological Mother'
    end

    it "finds that child has no relation to stranger1" do
      rel = child.relationship_to_person_via_participant(stranger1)
      rel.should == 'None'
    end

    it "finds that child has no relation to stranger2 who is not a participant" do
      rel = child.relationship_to_person_via_participant(stranger2)
      rel.should == 'None'
    end

    it "returns 'N/A' if given nil" do
      rel = child.relationship_to_person_via_participant(nil)
      rel.should == 'N/A'
    end

  end


end
