require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe PregnancyVisit do
  	include SurveyCompletion

    context 'class' do
      let(:populator) { PregnancyVisit }

      it_should_behave_like 'a survey title acceptor', '_PregVisit1_', '_PregVisit2_'
    end

    def assert_response_value(response_set, reference_identifier, value)
      response = response_set.responses.select { |r| r.question.reference_identifier == reference_identifier }.first
      response.should_not be_nil
      response.to_s.should == value
    end

    def init_instrument_and_response_set(event = nil)
			@response_set, @instrument = prepare_instrument(person, participant, survey, nil, event)
      @response_set.responses.should be_empty
    end

    def run_populator(event = nil, mode = nil)
    	init_instrument_and_response_set(event)
			PregnancyVisit.new(@response_set).tap do |p|
				p.mode = mode
			end.run
    end

    context "with pregnancy visit two instrument" do

      let(:person) { Factory(:person) }
      let(:participant) { Factory(:participant) }
      let(:survey) { create_pbs_pregnancy_visit_2_with_prepopulated_fields }
      let(:pv1_event) { Factory(:event, :event_type_code => 13) }
      let(:ic_event) { Factory(:event, :event_type_code => 10) }

      before(:each) do
        participant.person = person
        participant.save!
      end

      describe "prepopulated_is_work_name_previously_collected_and_valid" do

        it "should be FALSE if work name was not previously answered" do
        	run_populator
          assert_response_value(@response_set, "prepopulated_is_work_name_previously_collected_and_valid", "FALSE")
        end

        it "should be FALSE if work name was previously answered as refused" do
          pv1_survey = create_pv1_with_fields_for_pv2_prepopulation
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.refused "PREG_VISIT_1_3.WORK_NAME"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_is_work_name_previously_collected_and_valid", "FALSE")
        end

        it "should be FALSE if work name was previously answered as don't know" do
          pv1_survey = create_pv1_with_fields_for_pv2_prepopulation
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.dont_know "PREG_VISIT_1_3.WORK_NAME"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_is_work_name_previously_collected_and_valid", "FALSE")
        end

        it "should be TRUE if work name was previously answered" do
          pv1_survey = create_pv1_with_fields_for_pv2_prepopulation
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.a "PREG_VISIT_1_3.WORK_NAME", :value => "work_name"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_is_work_name_previously_collected_and_valid", "TRUE")
        end

      end

      describe "prepopulated_is_work_address_previously_collected_and_valid" do

        it "should be FALSE if work address was not previously answered" do
        	run_populator
          assert_response_value(@response_set, "prepopulated_is_work_address_previously_collected_and_valid", "FALSE")
        end

        it "should be FALSE if work address was previously answered as refused" do
          pv1_survey = create_pv1_with_fields_for_pv2_prepopulation
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.refused "PREG_VISIT_1_3.WORK_ADDRESS_1"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_is_work_address_previously_collected_and_valid", "FALSE")
        end

        it "should be FALSE if work address was previously answered as don't know" do
          pv1_survey = create_pv1_with_fields_for_pv2_prepopulation
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.dont_know "PREG_VISIT_1_3.WORK_ADDRESS_1"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_is_work_address_previously_collected_and_valid", "FALSE")
        end

        it "should be TRUE if work address was previously answered" do
          pv1_survey = create_pv1_with_fields_for_pv2_prepopulation
          pv1_response_set, pv1_instrument = prepare_instrument(person, participant, pv1_survey)

          take_survey(pv1_survey, pv1_response_set) do |r|
            r.a "PREG_VISIT_1_3.WORK_ADDRESS_1", :value => "work_address"
          end

          run_populator
          assert_response_value(@response_set, "prepopulated_is_work_address_previously_collected_and_valid", "TRUE")
        end

      end

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
          	run_populator
            assert_response_value(@response_set, "prepopulated_is_first_pregnancy_visit_one", "TRUE")
          end

          it "prepopulated_should_show_height should be TRUE" do
            run_populator
            assert_response_value(@response_set, "prepopulated_should_show_height", "TRUE")
          end

          describe "if OWN_HOME was asked during SCREENER" do
            # TODO: I don't see OWN_HOME as a question in the screener instruments
            it "prepopulated_should_show_recent_move_for_preg_visit_one should be TRUE"
          end

          describe "if OWN_HOME was asked during PRE-PREGANCY" do
            it "prepopulated_should_show_recent_move_for_preg_visit_one should be TRUE" do

              pre_preg_survey = create_pre_preg_survey_with_fields_used_in_pv1_prepopulation
              pre_preg_response_set, pre_preg_instrument = prepare_instrument(person, participant, pre_preg_survey)

              take_survey(pre_preg_survey, pre_preg_response_set) do |r|
                r.yes "PRE_PREG.OWN_HOME"
              end

              run_populator
              assert_response_value(@response_set, "prepopulated_should_show_recent_move_for_preg_visit_one", "TRUE")
            end

          end

          describe "if OWN_HOME was NOT asked previously" do
            it "prepopulated_should_show_recent_move_for_preg_visit_one should be FALSE" do
              run_populator
              assert_response_value(@response_set, "prepopulated_should_show_recent_move_for_preg_visit_one", "FALSE")
            end
          end

          describe "if RECENT_MOVE was asked during PRE-PREGANCY" do
            describe "and was coded as one" do

              it "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one should be TRUE" do
                pre_preg_survey = create_pre_preg_survey_with_fields_used_in_pv1_prepopulation
                pre_preg_response_set, pre_preg_instrument = prepare_instrument(person, participant, pre_preg_survey)

                take_survey(pre_preg_survey, pre_preg_response_set) do |r|
                  r.yes "PRE_PREG.RECENT_MOVE"
                end

                run_populator
                assert_response_value(@response_set,
                  "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one", "TRUE")
              end

            end

            describe "and was NOT coded as one" do
              it "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one should be FALSE" do
                pre_preg_survey = create_pre_preg_survey_with_fields_used_in_pv1_prepopulation
                pre_preg_response_set, pre_preg_instrument = prepare_instrument(person, participant, pre_preg_survey)

                take_survey(pre_preg_survey, pre_preg_response_set) do |r|
                  r.no "PRE_PREG.RECENT_MOVE"
                end

                run_populator
                assert_response_value(@response_set,
                  "prepopulated_is_pre_pregnancy_information_available_and_recent_move_coded_as_one", "FALSE")
              end
            end
          end

        end

        describe "the subsequent visit" do

          before(:each) do
            # create a completed pv1 event
            previous_pv1 = Factory(:event, :event_type_code => Event.pregnancy_visit_1_code,
              :event_end_date => '2025-12-25', :participant => participant)
            previous_contact = Factory(:contact)
            previous_contact_link = Factory(:contact_link, :person => person, :contact => previous_contact, :event => previous_pv1)
            # ensure that the event has been completed
            pv1_code = NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', Event.pregnancy_visit_1_code)
            person.participant.completed_event?(pv1_code).should be_true
          end

          it "prepopulated_is_first_pregnancy_visit_one should be FALSE" do
            run_populator
            assert_response_value(@response_set, "prepopulated_is_first_pregnancy_visit_one", "FALSE")
          end

          it "prepopulated_should_show_height should be FALSE" do
            run_populator(pv1_event)
            assert_response_value(@response_set, "prepopulated_should_show_height", "FALSE")
          end

          it "prepopulated_should_show_recent_move_for_preg_visit_one should be TRUE" do
            run_populator(pv1_event)
            assert_response_value(@response_set,
              "prepopulated_should_show_recent_move_for_preg_visit_one", "TRUE")
          end
        end

      end


      describe "for a contact that is" do

        let(:in_person) { NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 1) }
        let(:telephone) { NcsCode.for_list_name_and_local_code('CONTACT_TYPE_CL1', 3) }

        describe "in person" do
          it "prepopulated_mode_of_contact is set to CAPI" do
          	run_populator(nil, Instrument.capi)
            assert_response_value(@response_set, "prepopulated_mode_of_contact", "CAPI")
          end
        end

        describe "via telephone" do
          it "prepopulated_mode_of_contact is set to CATI" do
            run_populator(nil, Instrument.cati)
            assert_response_value(@response_set, "prepopulated_mode_of_contact", "CATI")
          end
        end

      end
    end
  end
end
