# == Schema Information
# Schema version: 20120507183332
#
# Table name: contacts
#
#  id                      :integer         not null, primary key
#  psu_code                :integer         not null
#  contact_id              :string(36)      not null
#  contact_disposition     :integer
#  contact_type_code       :integer         not null
#  contact_type_other      :string(255)
#  contact_date            :string(10)
#  contact_date_date       :date
#  contact_start_time      :string(255)
#  contact_end_time        :string(255)
#  contact_language_code   :integer         not null
#  contact_language_other  :string(255)
#  contact_interpret_code  :integer         not null
#  contact_interpret_other :string(255)
#  contact_location_code   :integer         not null
#  contact_location_other  :string(255)
#  contact_private_code    :integer         not null
#  contact_private_detail  :string(255)
#  contact_distance        :decimal(6, 2)
#  who_contacted_code      :integer         not null
#  who_contacted_other     :string(255)
#  contact_comment         :text
#  transaction_type        :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#

# -*- coding: utf-8 -*-

require 'spec_helper'

describe Contact do
  include SurveyCompletion

  it "should create a new instance given valid attributes" do
    c = Factory(:contact)
    c.should_not be_nil
  end

  it { should belong_to(:psu) }
  it { should belong_to(:contact_type) }
  it { should belong_to(:contact_language) }
  it { should belong_to(:contact_interpret) }
  it { should belong_to(:contact_location) }
  it { should belong_to(:contact_private) }
  it { should belong_to(:who_contacted) }

  it { should have_many(:contact_links) }

  it "knows when it is 'closed'" do
    c = Factory(:contact)
    c.should_not be_closed

    c.contact_disposition = 510
    c.should be_closed
    c.should be_completed
  end

  context "as mdes record" do

    it "sets the public_id to a uuid" do
      c = Factory(:contact)
      c.public_id.should_not be_nil
      c.contact_id.should == c.public_id
      c.contact_id.length.should == 36
    end

    it "uses the ncs_code 'Missing in Error' for all required ncs codes" do

      c = Contact.new
      c.save!

      obj = Contact.first
      obj.contact_type.local_code.should == -4
      obj.contact_language.local_code.should == -4
      obj.contact_interpret.local_code.should == -4
      obj.contact_location.local_code.should == -4
      obj.contact_private.local_code.should == -4
      obj.who_contacted.local_code.should == -4
    end
  end

  context "contact links and instruments" do

    before(:each) do
      @y = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)
      @n = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
      @q = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', -4)
    end

    it "knows all contact links associated with this contact" do

      c  = Factory(:contact)
      l1 = Factory(:contact_link, :contact => c)

      c.contact_links.should == [l1]

      l2 = Factory(:contact_link, :contact => c)

      c.contact_links.reload
      c.contact_links.should == [l1, l2]

    end

    it "knows all instruments associated with this contact" do
      c  = Factory(:contact)
      pers = Factory(:person)
      rs, i1 = prepare_instrument(pers, create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data)
      l1 = Factory(:contact_link, :contact => c, :instrument => i1, :person => pers)

      c.contact_links.should == [l1]
      c.instruments.should == [i1]

      rs, i2 = prepare_instrument(pers, create_pre_pregnancy_survey_with_email_operational_data)
      l2 = Factory(:contact_link, :contact => c, :instrument => i2, :person => pers)

      i3 = Factory(:instrument)
      l3 = Factory(:contact_link, :contact => c, :instrument => i3, :person => pers)

      c.contact_links.reload
      c.instruments.reload
      [l1, l2, l3].each { |ins| c.contact_links.should.should include(ins) }
      [i1, i2, i3].each { |ins| c.instruments.should include(ins) }
      [i1, i2].each { |ins| c.instruments_with_surveys.should include(ins) }
      [i1.survey.title, i2.survey.title].each { |t| c.instrument_survey_titles.should include(t) }
    end

    describe "setting the language and interpreter values" do

      before(:each) do

        @survey = create_survey_with_language_and_interpreter_data
        @person = Factory(:person)
        @english = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', 1)
        @spanish     = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', 2)
        @spanish_cl5 = NcsCode.for_list_name_and_local_code('LANGUAGE_CL5', 1)
        @farsi       = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', 17)
        @farsi_cl5   = NcsCode.for_list_name_and_local_code('LANGUAGE_CL5', 16)
        @other       = NcsCode.for_list_name_and_local_code('LANGUAGE_CL5', -5)

        @legitimate_skip  = NcsCode.for_list_name_and_local_code('TRANSLATION_METHOD_CL3', -3)
        @sign_interpreter = NcsCode.for_list_name_and_local_code('TRANSLATION_METHOD_CL3', 6)

      end

      it "sets the contact language to English if the instrument was taken in English" do

        contact = Factory(:contact, :contact_language => nil)
        person  = Factory(:person)

        response_set, instrument = prepare_instrument(person, @survey)

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        take_survey(@survey, response_set) do |a|
          a.yes "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        person = Person.find(person.id)

        contact.set_language_and_interpreter_data(person)
        contact.save!
        contact.contact_language.should == @english

      end

      it "sets the contact language to Spanish if the instrument was taken in Spanish" do
        contact = Factory(:contact, :contact_language => nil)
        person  = Factory(:person)

        response_set, instrument = prepare_instrument(person, @survey)

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        take_survey(@survey, response_set) do |a|
          a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG", @spanish_cl5
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        person = Person.find(person.id)

        contact.set_language_and_interpreter_data(person)
        contact.save!
        contact.contact_language.should == @spanish

      end

      it "sets the contact language to Farsi if the instrument was taken in Farsi" do
        contact = Factory(:contact, :contact_language => nil)
        person  = Factory(:person)

        response_set, instrument = prepare_instrument(person, @survey)

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        take_survey(@survey, response_set) do |a|
          a.no "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
          a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG", @farsi_cl5
        end

        response_set.responses.reload
        response_set.responses.size.should == 2

        person = Person.find(person.id)

        contact.set_language_and_interpreter_data(person)
        contact.save!
        contact.contact_language.should == @farsi

      end

      it "sets the contact language to some other specified language if the instrument was taken in some other specified language" do
        contact = Factory(:contact, :contact_language => nil)
        person  = Factory(:person)

        response_set, instrument = prepare_instrument(person, @survey)

        language_value = "Ojibwa"

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        take_survey(@survey, response_set) do |a|
          a.no "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
          a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG", @other
          a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG_OTH", language_value
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        person = Person.find(person.id)

        contact.set_language_and_interpreter_data(person)
        contact.save!
        contact.contact_language.local_code.should == -4
        contact.contact_language_other.should == language_value
      end

      it "sets the contact interpret to Legitimate Skip if no Interpreter was used" do

        contact = Factory(:contact, :contact_interpret => nil)
        person  = Factory(:person)

        response_set, instrument = prepare_instrument(person, @survey)

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        take_survey(@survey, response_set) do |a|
          a.no "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.INTERPRET"
        end

        response_set.responses.reload
        response_set.responses.size.should == 1

        person = Person.find(person.id)

        contact.set_language_and_interpreter_data(person)
        contact.save!
        contact.contact_interpret.should == @legitimate_skip

      end

      it "sets the contact interpret to the Interpreter that was used" do

        contact = Factory(:contact, :contact_interpret => nil)
        person  = Factory(:person)

        response_set, instrument = prepare_instrument(person, @survey)

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        take_survey(@survey, response_set) do |a|
          a.yes "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.INTERPRET"
          a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_INTERPRET", @sign_interpreter
        end

        response_set.responses.reload
        response_set.responses.size.should == 2

        person = Person.find(person.id)

        contact.set_language_and_interpreter_data(person)
        contact.save!
        contact.contact_interpret.should == @sign_interpreter

      end

      it "sets the contact interpret to the other interpreter method" do

        contact = Factory(:contact, :contact_interpret => nil)
        person  = Factory(:person)

        response_set, instrument = prepare_instrument(person, @survey)

        interpreter_value = "Other interpreter"

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        take_survey(@survey, response_set) do |a|
          a.yes "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.INTERPRET"
          a.choice "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_INTERPRET", @other
          a.str "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_INTERPRET_OTH", interpreter_value
        end

        response_set.responses.reload
        response_set.responses.size.should == 3

        person = Person.find(person.id)

        contact.set_language_and_interpreter_data(person)
        contact.save!
        contact.contact_interpret.local_code.should == -4
        contact.contact_interpret_other.should == interpreter_value

      end

    end

    describe "auto-completing MDES data" do

      before(:each) do

        @y = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 1)
        @n = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', 2)
        @q = NcsCode.for_list_name_and_local_code('CONFIRM_TYPE_CL2', -4)

        @ncs_participant = NcsCode.for_list_name_and_local_code('CONTACTED_PERSON_CL1', 1)

        @telephone = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3)
        @mail      = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 2)
        @in_person = NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1)

        @survey = create_survey_with_language_and_interpreter_data
        @person = Factory(:person)
        @english = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', 1)
        @spanish = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', 2)
                   NcsCode.for_list_name_and_local_code('LANGUAGE_CL5', 1)
        @farsi   = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', 17)
                   NcsCode.for_list_name_and_local_code('LANGUAGE_CL5', 16)

      end

      describe "for a telephone contact" do

        before(:each) do
          @contact = Factory(:contact, :contact_type => @telephone, :contact_language => nil, :contact_interpret => nil,
                                       :contact_location_code => nil, :contact_private => nil, :who_contacted => nil)
        end

        it "sets the who_contacted to the NCS Participant if there was an instrument taken" do
          response_set, instrument = prepare_instrument(@person, @survey)

          link = Factory(:contact_link, :contact => @contact, :instrument => instrument, :person => @person)

          @contact.populate_post_survey_attributes(instrument)
          @contact.save!
          @contact.who_contacted.should == @ncs_participant
        end

        it "does not set the who_contacted if there was no instrument" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.who_contacted.local_code.should == -4
        end

        it "sets the contact_location to NCS Site office" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_location.to_s == "NCS Site office"
        end

        it "sets the contact_private code to No and private_detail is nil" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_private.to_s.should == "No"
          @contact.contact_private_detail.should be_nil
        end

        it "sets the contact_distance to 0.0" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_distance.should == 0.0
        end

      end

      describe "for a mail contact" do

        before(:each) do
          @contact = Factory(:contact, :contact_type => @mail, :contact_language => nil, :contact_interpret => nil,
                                       :contact_location => nil, :contact_private => nil, :who_contacted => nil)
        end

        it "sets the contact_location to NCS Site office" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_location.to_s == "NCS Site office"
        end

        it "sets the contact_private code to No and private_detail is nil" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_private.to_s.should == "No"
          @contact.contact_private_detail.should be_nil
        end

        it "sets the contact_distance to 0.0" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_distance.should == 0.0
        end

      end

      describe "for an in person contact" do

        before(:each) do
          @contact = Factory(:contact, :contact_type => @in_person, :contact_language => nil, :contact_interpret => nil,
                                       :contact_location => nil, :contact_private => nil, :who_contacted => nil)
        end

        it "sets the who_contacted to the NCS Participant if there was an instrument taken" do

          response_set, instrument = prepare_instrument(@person, @survey)

          link = Factory(:contact_link, :contact => @contact, :instrument => instrument, :person => @person)

          @contact.populate_post_survey_attributes(instrument)
          @contact.save!
          @contact.who_contacted.should == @ncs_participant
        end

        it "does not set the who_contacted if there was no instrument" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.who_contacted.local_code.should == -4
        end

        it "sets the contact_location to missing in error" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_location.local_code.should == -4
        end

        it "sets the contact_private code to Yes" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_private.local_code.should == -4
        end

        it "sets the contact_private_detail to the text of the contact type" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_private_detail.should be_nil
        end

        it "sets the contact_distance to 0.0" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_distance.should be_nil
        end

      end

      describe "setting the disposition based on instrument responses" do

        it "sets the disposition to complete in English"

        it "sets the disposition to complete in Spanish"

        it "sets the disposition to complete in Other Language"

      end

    end

  end

  context "last contact for a participant" do

    it "returns the last contact for a participant" do
    end

  end

end
