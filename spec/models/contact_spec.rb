# == Schema Information
# Schema version: 20111212224350
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

require 'spec_helper'

describe Contact do
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
      create_missing_in_error_ncs_codes(Contact)

      c = Contact.new
      c.psu = Factory(:ncs_code)
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
      create_missing_in_error_ncs_codes(Instrument)
      @y = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "Yes", :local_code => 1)
      @n = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "No",  :local_code => 2)
      @q = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "?",   :local_code => -4)
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
      rs, i1 = pers.start_instrument(create_li_pregnancy_screener_survey_with_ppg_status_history_operational_data)
      l1 = Factory(:contact_link, :contact => c, :instrument => i1, :person => pers)

      c.contact_links.should == [l1]
      c.instruments.should == [i1]

      rs, i2 = pers.start_instrument(create_pre_pregnancy_survey_with_email_operational_data)
      l2 = Factory(:contact_link, :contact => c, :instrument => i2, :person => pers)

      i3 = Factory(:instrument)
      l3 = Factory(:contact_link, :contact => c, :instrument => i3, :person => pers)

      c.contact_links.reload
      c.instruments.reload
      c.contact_links.should == [l1, l2, l3]
      c.instruments.should == [i1, i2, i3]
      c.instruments_with_surveys.should == [i1, i2]
      c.instrument_survey_titles.should == [i1.survey.title, i2.survey.title]
    end

    describe "setting the language and interpreter values" do

      before(:each) do
        create_missing_in_error_ncs_codes(Contact)

        @survey = create_survey_with_language_and_interpreter_data
        @person = Factory(:person)
        @english = Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :display_text => 'English', :local_code => 1)
        @spanish = Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :display_text => 'Spanish', :local_code => 2)
                   Factory(:ncs_code, :list_name => 'LANGUAGE_CL5', :display_text => 'Spanish', :local_code => 1)
        @farsi   = Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :display_text => 'Farsi',   :local_code => 17)
                   Factory(:ncs_code, :list_name => 'LANGUAGE_CL5', :display_text => 'Farsi',   :local_code => 16)

        @legitimate_skip  = Factory(:ncs_code, :list_name => 'TRANSLATION_METHOD_CL3', :display_text => 'Legitimate Skip', :local_code => -3)
        @sign_interpreter = Factory(:ncs_code, :list_name => 'TRANSLATION_METHOD_CL3', :display_text => 'Sign Language Interpreter', :local_code => 6)

      end

      it "sets the contact language to English if the instrument was taken in English" do

        contact = Factory(:contact, :contact_language => nil)
        person  = Factory(:person)

        survey_section = @survey.sections.first
        response_set, instrument = person.start_instrument(@survey)
        response_set.responses.size.should == 0

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
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

        survey_section = @survey.sections.first
        response_set, instrument = person.start_instrument(@survey)
        response_set.responses.size.should == 0

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
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

        survey_section = @survey.sections.first
        response_set, instrument = person.start_instrument(@survey)
        response_set.responses.size.should == 0

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "2" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "16" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
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

        survey_section = @survey.sections.first
        response_set, instrument = person.start_instrument(@survey)
        response_set.responses.size.should == 0

        language_value = "Ojibwa"

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.ENGLISH"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "2" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "-5" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_LANG_OTH"
            answer = q.answers.select { |a| a.response_class == "string" }.first
            Factory(:response, :survey_section_id => survey_section.id, :string_value => language_value, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
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

        survey_section = @survey.sections.first
        response_set, instrument = person.start_instrument(@survey)
        response_set.responses.size.should == 0

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.INTERPRET"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "2" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
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

        survey_section = @survey.sections.first
        response_set, instrument = person.start_instrument(@survey)
        response_set.responses.size.should == 0

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.INTERPRET"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_INTERPRET"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "6" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
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

        survey_section = @survey.sections.first
        response_set, instrument = person.start_instrument(@survey)
        response_set.responses.size.should == 0

        interpreter_value = "Other interpreter"

        link = Factory(:contact_link, :contact => contact, :instrument => instrument, :person => person)

        survey_section.questions.each do |q|
          case q.data_export_identifier
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.INTERPRET"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "1" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_INTERPRET"
            answer = q.answers.select { |a| a.response_class == "answer" && a.reference_identifier == "-5" }.first
            Factory(:response, :survey_section_id => survey_section.id, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          when "#{PregnancyScreenerOperationalDataExtractor::INTERVIEW_PREFIX}.CONTACT_INTERPRET_OTH"
            answer = q.answers.select { |a| a.response_class == "string" }.first
            Factory(:response, :survey_section_id => survey_section.id, :string_value => interpreter_value, :question_id => q.id, :answer_id => answer.id, :response_set_id => response_set.id)
          end
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
        create_missing_in_error_ncs_codes(Contact)

        @y = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "Yes", :local_code => 1)
        @n = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "No",  :local_code => 2)
        @q = Factory(:ncs_code, :list_name => 'CONFIRM_TYPE_CL2', :display_text => "?",   :local_code => -4)

        @ncs_participant = Factory(:ncs_code, :list_name => 'CONTACTED_PERSON_CL1', :display_text => "NCS Participant", :local_code => 1)

        @telephone = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Telephone', :local_code => 3)
        @mail      = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'Mail', :local_code => 2)
        @in_person = Factory(:ncs_code, :list_name => 'CONTACT_TYPE_CL1', :display_text => 'In-Person', :local_code => 1)

        @survey = create_survey_with_language_and_interpreter_data
        @person = Factory(:person)
        @english = Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :display_text => 'English', :local_code => 1)
        @spanish = Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :display_text => 'Spanish', :local_code => 2)
                   Factory(:ncs_code, :list_name => 'LANGUAGE_CL5', :display_text => 'Spanish', :local_code => 1)
        @farsi   = Factory(:ncs_code, :list_name => 'LANGUAGE_CL2', :display_text => 'Farsi',   :local_code => 17)
                   Factory(:ncs_code, :list_name => 'LANGUAGE_CL5', :display_text => 'Farsi',   :local_code => 16)

      end

      describe "for a telephone contact" do

        before(:each) do
          @contact = Factory(:contact, :contact_type => @telephone, :contact_language => nil, :contact_interpret => nil,
                                       :contact_location => nil, :contact_private => nil, :who_contacted => nil)
        end

        it "sets the who_contacted to the NCS Participant if there was an instrument taken" do

          response_set, instrument = @person.start_instrument(@survey)
          response_set.responses.size.should == 0

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
          @contact.contact_private.to_s.should == "Yes"
        end

        it "sets the contact_private_detail to the text of the contact type" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_private_detail.should == @contact.contact_type.to_s
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

        it "sets the contact_location to missing in error" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_location.local_code.should == -4
        end

        it "sets the contact_private code to Yes" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_private.to_s.should == "Yes"
        end

        it "sets the contact_private_detail to the text of the contact type" do
          @contact.populate_post_survey_attributes(nil)
          @contact.save!
          @contact.contact_private_detail.should == @contact.contact_type.to_s
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

          response_set, instrument = @person.start_instrument(@survey)
          response_set.responses.size.should == 0

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

end
