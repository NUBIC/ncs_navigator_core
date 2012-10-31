# -*- coding: utf-8 -*-

require 'spec_helper'

module NcsNavigator::Core

  describe ResponseSetPopulator::PregnancyVisit do
    include SurveyCompletion

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

    context "with pregnancy visit one instrument" do

      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }
      let(:survey) { create_pregnancy_visit_survey_with_prepopulated_fields }
      let(:pv1_event) { Factory(:event, :event_type_code => 13) }
      let(:ic_event) { Factory(:event, :event_type_code => 10) }

      before(:each) do
        participant.person = person
        participant.save!

        @response_set, @instrument = prepare_instrument(person, participant, survey)
        @response_set.responses.should be_empty
      end

      describe "for one or more contacts" do

        before(:each) do
          # create contact for other event
          ic_contact = Factory(:contact)
          ic_contact_link = Factory(:contact_link, :person => person, :contact => ic_contact, :event => ic_event)
          # ensure that there is no contact for pv1 yet
          person.contact_links.select { |cl| cl.event.try(:event_type_code) == 13 }.should be_empty
        end

        describe "the first visit" do

          it "prepopulated_is_first_pregnancy_visit_one should be TRUE" do
            params = { :person => person, :instrument => @instrument, :survey => survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process,
              "prepopulated_is_first_pregnancy_visit_one", "TRUE")
          end

          it "prepopulated_should_show_height should be TRUE" do
            params = { :person => person, :instrument => @instrument, :survey => survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process,
              "prepopulated_should_show_height", "TRUE")
          end

          describe "if OWN_HOME was asked during SCREENER" do
            # TODO: I don't see OWN_HOME as a question in the screener instruments
            it "prepopulated_should_show_recent_move_for_preg_visit_one should be TRUE"
          end

          describe "if OWN_HOME was asked during PRE-PREGANCY" do
            it "prepopulated_should_show_recent_move_for_preg_visit_one should be TRUE" do

              pre_preg_survey = create_pre_preg_survey_with_fields_used_in_pv1_prepopulation
              pre_preg_response_set, pre_preg_instrument = prepare_instrument(person, participant, pre_preg_survey)

              yes = mock(NcsCode, :local_code => 1)
              take_survey(pre_preg_survey, pre_preg_response_set) do |a|
                a.choice "PRE_PREG.OWN_HOME", yes
              end

              params = { :person => person, :instrument => @instrument, :survey => survey }
              assert_response_value(ResponseSetPopulator::Base.new(params).process,
                "prepopulated_should_show_recent_move_for_preg_visit_one", "TRUE")
            end

          end

          describe "if OWN_HOME was NOT asked previously" do
            it "prepopulated_should_show_recent_move_for_preg_visit_one should be FALSE" do
              params = { :person => person, :instrument => @instrument, :survey => survey }
              assert_response_value(ResponseSetPopulator::Base.new(params).process,
                "prepopulated_should_show_recent_move_for_preg_visit_one", "FALSE")
            end
          end

          describe "if RECENT_MOVE was asked during PRE-PREGANCY" do
            describe "and was coded as one" do

              it "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one should be TRUE" do
                pre_preg_survey = create_pre_preg_survey_with_fields_used_in_pv1_prepopulation
                pre_preg_response_set, pre_preg_instrument = prepare_instrument(person, participant, pre_preg_survey)

                yes = mock(NcsCode, :local_code => 1)
                take_survey(pre_preg_survey, pre_preg_response_set) do |a|
                  a.choice "PRE_PREG.RECENT_MOVE", yes
                end

                params = { :person => person, :instrument => @instrument, :survey => survey }
                assert_response_value(ResponseSetPopulator::Base.new(params).process,
                  "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one", "TRUE")
              end

            end

            describe "and was NOT coded as one" do
              it "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one should be FALSE" do
                pre_preg_survey = create_pre_preg_survey_with_fields_used_in_pv1_prepopulation
                pre_preg_response_set, pre_preg_instrument = prepare_instrument(person, participant, pre_preg_survey)

                no = mock(NcsCode, :local_code => 2)
                take_survey(pre_preg_survey, pre_preg_response_set) do |a|
                  a.choice "PRE_PREG.RECENT_MOVE", no
                end

                params = { :person => person, :instrument => @instrument, :survey => survey }
                assert_response_value(ResponseSetPopulator::Base.new(params).process,
                  "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one", "FALSE")
              end
            end
          end

        end

        describe "the subsequent visit" do

          before(:each) do
            # create two contacts for pv1
            contact1 = Factory(:contact)
            contact2 = Factory(:contact)
            @contact_link1 = Factory(:contact_link, :person => person, :contact => contact1, :event => pv1_event)
            @contact_link2 = Factory(:contact_link, :person => person, :contact => contact2, :event => pv1_event)
            # ensure that there are two contacts for pv1
            person.contact_links.reload
            person.contact_links.select { |cl| cl.event.try(:event_type_code) == 13 }.size.should == 2
          end

          it "prepopulated_is_first_pregnancy_visit_one should be FALSE" do
            params = { :person => person, :instrument => @instrument, :survey => survey }
            assert_response_value(ResponseSetPopulator::Base.new(params).process,
              "prepopulated_is_first_pregnancy_visit_one", "FALSE")
          end

          it "prepopulated_should_show_height should be FALSE" do
            params = { :person => person, :instrument => @instrument, :survey => survey, :contact_link => @contact_link2 }
            assert_response_value(ResponseSetPopulator::Base.new(params).process,
              "prepopulated_should_show_height", "FALSE")
          end

          it "prepopulated_should_show_recent_move_for_preg_visit_one should be TRUE" do
            params = { :person => person, :instrument => @instrument, :survey => survey, :contact_link => @contact_link2 }
            assert_response_value(ResponseSetPopulator::Base.new(params).process,
              "prepopulated_should_show_recent_move_for_preg_visit_one", "TRUE")
          end

              # PROGRAMMER INSTRUCTIONS:
    # - IF FIRST PREGNANCY VISIT 1 INTERVIEW:
    # -   IF OWN_HOME WAS ASKED DURING PREGNANCY SCREENER OR PRE-PREGANCY VISIT, THEN ASK RECENT_MOVE.
    # -   OTHERWISE, GO TO OWN_HOME.
    # - IF SUBSEQUENT PREGNANCY VISIT 1 INTERVIEW:
    # -   GO TO RECENT_MOVE

        end

      end


      describe "for a contact that is" do

        let(:in_person) { NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1) }
        let(:telephone) { NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3) }

        describe "in person" do
          it "prepopulated_mode_of_contact is set to CAPI" do
            contact = Factory(:contact, :contact_type => in_person)
            contact_link = Factory(:contact_link, :person => person, :contact => contact)

            params = { :person => person, :instrument => @instrument, :survey => survey, :contact_link => contact_link }
            assert_response_value(ResponseSetPopulator::Base.new(params).process,
              "prepopulated_mode_of_contact", "CAPI")
          end
        end

        describe "via telephone" do
          it "prepopulated_mode_of_contact is set to CATI" do
            contact = Factory(:contact, :contact_type => telephone)
            contact_link = Factory(:contact_link, :person => person, :contact => contact)

            params = { :person => person, :instrument => @instrument, :survey => survey, :contact_link => contact_link }
            assert_response_value(ResponseSetPopulator::Base.new(params).process,
              "prepopulated_mode_of_contact", "CATI")
          end
        end

      end
    end
  end
end