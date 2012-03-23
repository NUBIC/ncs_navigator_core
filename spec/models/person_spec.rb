# == Schema Information
# Schema version: 20120321181032
#
# Table name: people
#
#  id                             :integer         not null, primary key
#  psu_code                       :integer         not null
#  person_id                      :string(36)      not null
#  prefix_code                    :integer         not null
#  first_name                     :string(30)
#  last_name                      :string(30)
#  middle_name                    :string(30)
#  maiden_name                    :string(30)
#  suffix_code                    :integer         not null
#  title                          :string(5)
#  sex_code                       :integer         not null
#  age                            :integer
#  age_range_code                 :integer         not null
#  person_dob                     :string(10)
#  person_dob_date                :date
#  deceased_code                  :integer         not null
#  ethnic_group_code              :integer         not null
#  language_code                  :integer         not null
#  language_other                 :string(255)
#  marital_status_code            :integer         not null
#  marital_status_other           :string(255)
#  preferred_contact_method_code  :integer         not null
#  preferred_contact_method_other :string(255)
#  planned_move_code              :integer         not null
#  move_info_code                 :integer         not null
#  when_move_code                 :integer         not null
#  date_move_date                 :date
#  date_move                      :string(7)
#  p_tracing_code                 :integer         not null
#  p_info_source_code             :integer         not null
#  p_info_source_other            :string(255)
#  p_info_date                    :date
#  p_info_update                  :date
#  person_comment                 :text
#  transaction_type               :string(36)
#  created_at                     :datetime
#  updated_at                     :datetime
#  being_processed                :boolean
#  response_set_id                :integer
#

require 'spec_helper'

describe Person do
  before(:each) do
    Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)
    @y = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "Yes", :local_code => 1)
    @n = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "No",  :local_code => 2)
    @q = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "?",   :local_code => -4)
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

  it { should belong_to(:psu) }
  it { should belong_to(:prefix) }
  it { should belong_to(:suffix) }
  it { should belong_to(:sex) }
  it { should belong_to(:age_range) }
  it { should belong_to(:deceased) }
  it { should belong_to(:ethnic_group) }
  it { should belong_to(:language) }
  it { should belong_to(:marital_status) }
  it { should belong_to(:preferred_contact_method) }
  it { should belong_to(:planned_move) }
  it { should belong_to(:move_info) }
  it { should belong_to(:when_move) }
  it { should belong_to(:p_tracing) }
  it { should belong_to(:p_info_source) }

  # it { should validate_presence_of(:first_name) }
  # it { should validate_presence_of(:last_name) }

  it { should belong_to(:response_set) }
  it { should have_many(:response_sets) }
  it { should have_many(:contact_links) }
  it { should have_many(:participant_person_links) }
  it { should have_many(:participants).through(:participant_person_links) }

  it { should have_many(:household_person_links) }
  it { should have_many(:household_units).through(:household_person_links) }

  it { should have_many(:addresses) }
  it { should have_many(:telephones) }
  it { should have_many(:emails) }

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      pers = Factory(:person)
      pers.public_id.should_not be_nil
      pers.person_id.should == pers.public_id
      pers.person_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do
      create_missing_in_error_ncs_codes(Person)

      pers = Person.new
      pers.psu = Factory(:ncs_code)
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
  end

  context "determining age" do

    it "returns the person's age" do
      pers = Factory(:person, :person_dob_date => 10.years.ago)
      pers.age.should == 10
    end

    it "does not blowup on leap year" do
      dob = Date.parse('02/29/1992')
      pers = Factory(:person, :person_dob_date => dob)
      (pers.age > 18).should be_true
    end

    it "does not return anything if person dob is unknown" do
      pers = Factory(:person)
      pers.person_dob_modifier = "unknown"
      pers.save!

      Person.last.age.should be_nil
    end

    it "does not return anything if person dob is refused" do
      pers = Factory(:person)
      pers.person_dob_modifier = "refused"
      pers.save!

      Person.last.age.should be_nil
    end

    it "handles a string date" do
      dob = 10.years.ago
      pers = Factory(:person, :person_dob_date => nil, :person_dob => dob.strftime('%Y-%m-%d'))
      pers.age.should == 10
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
        pers.age.should be_nil
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

  context "with a contact" do

    it "gets an incomplete contact/contact link" do
      pers = Factory(:person)
      pers.current_contact_link.should be_nil

      link = Factory(:contact_link, :person => pers)
      pers.contact_links.reload
      pers.current_contact_link.should eq link

      pers.current_contact_link.contact.contact_disposition = 510
      pers.current_contact_link.event.event_disposition = 510
      pers.current_contact_link.should be_nil

    end

  end

  context "with a response set" do

    before(:each) do
      create_missing_in_error_ncs_codes(Instrument)
      InstrumentEventMap.stub!(:version).and_return("1.0")
      InstrumentEventMap.stub!(:instrument_type).and_return(Factory(:ncs_code, :list_name => 'INSTRUMENT_TYPE_CL1'))
      @pers = Factory(:person)
      @survey = create_test_survey_for_person
      @rs, @instrument = @pers.start_instrument(@survey)

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
      create_missing_in_error_ncs_codes(Instrument)
    end

    it "should get responses by data_export_identifier" do
      person = Factory(:person)

      survey = create_pregnancy_screener_survey_with_cell_phone_permissions
      survey_section = survey.sections.first
      response_set, instrument = person.start_instrument(survey)
      response_set.save!

      response_set.responses.size.should == 0

      survey_section.questions.each do |q|
        case q.data_export_identifier
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_2"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_4"
          answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
          Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
        end
      end

      response_set.responses.reload
      response_set.responses.size.should == 2

      person  = Person.find(person.id)
      can_use_phone_to_setup_appts = person.responses_for("#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_2")
      can_use_phone_to_setup_appts.size.should == 1
      can_use_phone_to_setup_appts.first.to_s.should == "Yes"

      can_text_to_setup_appts = person.responses_for("#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CELL_PHONE_4")
      can_text_to_setup_appts.size.should == 1
      can_text_to_setup_appts.first.to_s.should == "Yes"
    end

    context "repeating the instrument" do

      before(:each) do
        create_missing_in_error_ncs_codes(Instrument)
        InstrumentEventMap.stub!(:version).and_return("1.0")
        InstrumentEventMap.stub!(:instrument_type).and_return(Factory(:ncs_code, :list_name => 'INSTRUMENT_TYPE_CL1'))
        @person = Factory(:person)
        @survey = create_test_survey_for_person
      end

      it "returns 0 for the instrument_repeat_key if this is the first time taking the instrument" do
        response_set, instrument = @person.start_instrument(@survey)
        @person.instrument_repeat_key(instrument.survey).should == 0
      end

      it "returns 1 for the instrument_repeat_key if this is the second time taking the instrument" do
        response_set0, instrument0 = @person.start_instrument(@survey)
        response_set1, instrument1 = @person.start_instrument(@survey)
        response_set0.save!
        response_set1.save!

        @person.instrument_repeat_key(instrument1.survey).should == 1
      end

    end

    context "setting default instrument values" do

      before(:each) do
        create_missing_in_error_ncs_codes(Instrument)
        InstrumentEventMap.stub!(:version).and_return("1.0")
        InstrumentEventMap.stub!(:instrument_type).and_return(Factory(:ncs_code, :list_name => 'INSTRUMENT_TYPE_CL1'))
        @person = Factory(:person)
        @survey = create_test_survey_for_person

      end

      it "should set the supervisor_review_code" do
        response_set, instrument = @person.start_instrument(@survey)
        instrument.supervisor_review.should == @n
      end

      it "should set the data_problem_code" do
        response_set, instrument = @person.start_instrument(@survey)
        instrument.data_problem.should == @n
      end

      it "should set the instrument_mode_code" do
        telephone_computer_administered = Factory(:ncs_code, :list_name => 'INSTRUMENT_ADMIN_MODE_CL1', :local_code => 2, :display_text => "Telephone, Computer Assisted (CATI)")
        response_set, instrument = @person.start_instrument(@survey)
        instrument.instrument_mode.should == telephone_computer_administered
      end

      it "should set the instrument_method_code" do
        interviewer_administered = Factory(:ncs_code, :list_name => 'INSTRUMENT_ADMIN_METHOD_CL1', :local_code => 2, :display_text => "Interviewer Administered")
        response_set, instrument = @person.start_instrument(@survey)
        instrument.instrument_method.should == interviewer_administered
      end

      it "should set the instrument_breakoff_code"

      it "should set the instrument_status_code"

    end

  end

  context "determining ssu and tsu" do

    let(:person) { Factory(:person) }

    it "is not in a tsu if there are no households" do
      person.household_units.should be_empty
      person.should_not be_in_tsu
    end

    it "is not in a tsu if there are no dwelling units" do
      person.dwelling_units.should be_empty
      person.should_not be_in_tsu
    end

    it "is in a tsu if the dwelling unit for the household has a tsu id" do
      du = Factory(:dwelling_unit, :ssu_id => 'ssu', :tsu_id => 'tsu')
      hh = Factory(:household_unit)
      dh_link = Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hh)
      hh_pers_link = Factory(:household_person_link, :household_unit => hh, :person => person)
      person.household_units.should == [hh]
      person.dwelling_units.should == [du]
      person.dwelling_units.first.tsu_id.should == 'tsu'
      person.should be_in_tsu
    end

    it "is NOT in a tsu if the dwelling unit for the household does NOT have a tsu id" do
      du = Factory(:dwelling_unit, :ssu_id => 'ssu', :tsu_id => nil)
      hh = Factory(:household_unit)
      dh_link = Factory(:dwelling_household_link, :dwelling_unit => du, :household_unit => hh)
      hh_pers_link = Factory(:household_person_link, :household_unit => hh, :person => person)
      person.household_units.should == [hh]
      person.dwelling_units.should == [du]
      person.dwelling_units.first.tsu_id.should be_nil
      person.should_not be_in_tsu
    end

  end

end
