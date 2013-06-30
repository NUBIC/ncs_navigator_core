require 'spec_helper'

require File.expand_path('../a_survey_title_acceptor', __FILE__)

module ResponseSetPrepopulation
  describe Postnatal do
    include SurveyCompletion

    it_should_behave_like 'a survey title acceptor', '_3Month_', '_12Month_', '_3MMother_', '_12MMother_', '_Core_' do
      let(:populator) { Postnatal }
    end

    def get_response_as_string(response_set, reference_identifier)
      response = response_set.responses.select { |r|
        r.question.reference_identifier == reference_identifier
      }.first
      response.to_s
    end

    def init_common_vars
      @participant = Factory(:participant)
      @person = Factory(:person)
      @participant.person = @person
      @participant.save!
      @response_set, @instrument = prepare_instrument(@person, @participant,
                                                      @survey)
      @response_set.responses.should be_empty
    end

    def prepare_and_take_survey(question_dexp_identifier = nil, answer = nil,
                                survey_template = nil, survey = nil, &block)
      survey = send(survey_template) if survey_template
      response_set, instrument = prepare_instrument(@person, @participant,
                                                    survey)
      response_set.responses.should be_empty

      unless block_given?
        answer_code = mock(NcsCode, :local_code => answer)
        block = Proc.new { |r| r.a question_dexp_identifier, answer_code }
      end

      take_survey(survey, response_set, &block)
    end

    def complete_event(event)
      event.event_disposition_category_code = 3 # General Study Visit Event Code
      event.event_disposition = 60 # Completed Consent/Interview in English
      event.save!
    end

    def make_contact(event_type_code, event_complete = true)
      event = Factory(:event, :event_type_code => event_type_code,
                      :participant => @participant)
      complete_event(event) if event_complete

      contact = Factory(:contact)
      contact_link = Factory(:contact_link, :person => @person,
                              :contact => contact, :event => event)
      ncs_code = NcsCode::for_list_name_and_local_code('EVENT_TYPE_CL1',
                                                        event_type_code)
      event
    end

    def take_num_hh_surveys(survey_type, valid_answers)
      create_num_hh_for_18_and_24_month(survey_type
                                            ) do |survey, data_export_id|
        if valid_answers
          prepare_and_take_survey(nil, nil, nil, survey) do |r|
            r.a data_export_id, 'number', :value => 5
          end
        else
          answer_code = mock(NcsCode, :local_code => "neg_1")
          prepare_and_take_survey(nil, nil, nil, survey) do |r|
            r.a data_export_id, answer_code
          end
        end
      end
    end

    def run_populator
      Postnatal.new(@response_set).run
    end

    context "for work name and work address prepoulators"
      def take_work_surveys(title, data_export_id, valid_answers)
        survey = create_work_name_and_address_survey(title)
        if valid_answers
          prepare_and_take_survey(nil, nil, nil, survey) do |r|
            r.a(data_export_id, valid_answers)
          end
        else
          prepare_and_take_survey(nil, nil, nil, survey) do |r|
            r.refused(data_export_id)
          end
        end
      end

      describe "prepopulated_is_valid_work_address_provided" do
        it "should be TRUE when valid answer to sureveys using WORK_ADDRESS_1 exists." do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_24Month_INT_EHPBHILIPBS_M3.1_V3.0_PART_TWO",
                      "prepopulated_is_valid_work_address_provided")
          init_common_vars
          take_work_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO",
                            "BIRTH_VISIT_LI_2.WORK_ADDRESS_1", '888 Street')
          run_populator
          get_response_as_string(@response_set,
                "prepopulated_is_valid_work_address_provided").should == "TRUE"
        end

        it "should be TRUE when valid answer to sureveys using CWORK_ADDRESS_1 exists." do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_24Month_INT_EHPBHILIPBS_M3.1_V3.0_PART_TWO",
                      "prepopulated_is_valid_work_address_provided")
          init_common_vars
          take_work_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO",
                            "BIRTH_VISIT_LI_2.CWORK_ADDRESS_1", '888 Street')
          run_populator
          get_response_as_string(@response_set,
                "prepopulated_is_valid_work_address_provided").should == "TRUE"
        end

        it "should be TRUE when valid answer to sureveys using WORK_ADDRESS1 exists." do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO",
                      "prepopulated_is_valid_work_address_provided")
          init_common_vars
          take_work_surveys("INS_QUE_Birth_INT_M3.2_V3.1_PART_TWO",
                            "BIRTH_VISIT_4.WORK_ADDRESS1", '888 Street')
          run_populator
          get_response_as_string(@response_set,
                "prepopulated_is_valid_work_address_provided").should == "TRUE"
        end

        it "should be FALSE when only invalid answers to work address exist" do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_24Month_INT_EHPBHILIPBS_M3.1_V3.0_PART_TWO",
                      "prepopulated_is_valid_work_address_provided")
          init_common_vars
          take_work_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO",
                            "BIRTH_VISIT_LI_2.WORK_ADDRESS_1", false)
          run_populator
          get_response_as_string(@response_set,
                "prepopulated_is_valid_work_address_provided").should == "FALSE"
        end

        it "should be FALSE when only no answers to work address exist" do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_24Month_INT_EHPBHILIPBS_M3.1_V3.0_PART_TWO",
                      "prepopulated_is_valid_work_address_provided")
          init_common_vars
          run_populator
          get_response_as_string(@response_set,
                "prepopulated_is_valid_work_address_provided").should == "FALSE"
        end
      end

      describe "prepopulated_is_valid_work_name_provided" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_24Month_INT_EHPBHILIPBS_M3.1_V3.0_PART_TWO",
                      "prepopulated_is_valid_work_name_provided")
          init_common_vars
        end

        it "should be TRUE when valid answers to work name exist" do
          take_work_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO",
                            "BIRTH_VISIT_LI_2.WORK_NAME", 'The Work')
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_is_valid_work_name_provided").should == "TRUE"
        end

        it "should be FALSE when only invalid answers to work name exist" do
          take_work_surveys("INS_QUE_Birth_INT_LI_M3.1_V2.0_PART_TWO",
                            "BIRTH_VISIT_LI_2.WORK_NAME", false)
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_is_valid_work_name_provided").should == "FALSE"
        end

        it "should be FALSE when only no answers to work name exist" do
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_is_valid_work_name_provided").should == "FALSE"
        end
      end

      describe "prepopulated_should_show_num_hh_group" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_24Month_INT_EHPBHILIPBS_M3.1_V3.0_PART_ONE",
                      "prepopulated_should_show_num_hh_group")
          init_common_vars
        end

        it "should be FALSE when valid answers to NUM_HH exist" do
          take_num_hh_surveys("24M", true)
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_should_show_num_hh_group").should == "FALSE"
        end

        it "should be TRUE when only invalid answers to NUM_HH exist" do
          take_num_hh_surveys("24M", false)
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_should_show_num_hh_group").should == "TRUE"
        end

        it "should be TRUE when no responses to NUM_HH exist" do
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_should_show_num_hh_group").should == "TRUE"
        end
      end

    context "for 18M part one prepopulators"
      describe "prepopulated_should_show_num_hh_group" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_18Month_INT_EHPBHILIPBS_M3.1_V3.0_PART_ONE",
                      "prepopulated_should_show_num_hh_group")
          init_common_vars
        end

        it "should be FALSE when valid answers to NUM_HH exist" do
          take_num_hh_surveys("18M", true)
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_should_show_num_hh_group").should == "FALSE"
        end

        it "should be TRUE when only invalid answers to NUM_HH exist" do
          take_num_hh_surveys("18M", false)
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_should_show_num_hh_group").should == "TRUE"
        end

        it "should be TRUE when no responses to NUM_HH exist" do
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_should_show_num_hh_group").should == "TRUE"
        end
      end

    context "for 12MM mother detail prepopulators"
      describe "prepopulated_mult_child_answer_from_part_one_for_12MM" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                "INS_QUE_12MMother_INT_EHPBHI_P2_V11_TWELVE_MTH_MOTHER_DETAIL",
                "prepopulated_mult_child_answer_from_part_one_for_12MM")
          init_common_vars
        end

        it "should be TRUE when answer to MULT_CHILD from part one is YES" do
          prepare_and_take_survey("TWELVE_MTH_MOTHER.MULT_CHILD", NcsCode::YES,
                                  :create_12mm_part_one_mult_child)
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_mult_child_answer_from_part_one_for_12MM"
                ).should == "TRUE"
        end

        it "should be FALSE when answer to MULT_CHILD from part one is NO" do
          prepare_and_take_survey("TWELVE_MTH_MOTHER.MULT_CHILD", NcsCode::NO,
                                  :create_12mm_part_one_mult_child)
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_mult_child_answer_from_part_one_for_12MM"
                ).should == "FALSE"
        end

        it "should be TRUE when there's no answer to MULT_CHILD from part one" do
          run_populator
          get_response_as_string(@response_set,
                        "prepopulated_mult_child_answer_from_part_one_for_12MM"
                ).should == "FALSE"
        end
      end

    context "for 6Month part two prepopulators"
      describe "prepopulated_is_resp_rel_new" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_6Month_INT_EHPBHIPBS_M3.1_V2.0_PART_TWO",
                      "prepopulated_is_resp_rel_new")
          init_common_vars
        end

        it "should be TRUE if RESP_REL_NEW is set to biological mother (1)" do
          prepare_and_take_survey("PARTICIPANT_VERIF.RESP_REL_NEW", 1, # Mother
                                  :create_participant_verif_m_3_0)
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_resp_rel_new").should == "TRUE"
        end

        it "should be FALSE if RESP_REL_NEW isn't set to mother (not 1)" do
          prepare_and_take_survey("PARTICIPANT_VERIF.RESP_REL_NEW",
                                  2, # Not Mother
                                  :create_participant_verif_m_3_0)
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_resp_rel_new").should == "FALSE"
        end

        it "should be FALSE if RESP_REL_NEW isn't set at all" do
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_resp_rel_new").should == "FALSE"
        end
      end

      describe "prepopulated_is_multiple_child" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_6Month_INT_EHPBHIPBS_M3.1_V2.0_PART_TWO",
                      "prepopulated_is_child_qnum_one")
          init_common_vars
        end

        it "should be TRUE if child number is 1" do
          prepare_and_take_survey(nil, nil,
                                  :create_participant_verif_m_3_0) do |r|
            r.a "PARTICIPANT_VERIF.CHILD_QNUM", 'number', :value => 1
          end
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_child_qnum_one").should == "TRUE"
        end

        it "should be FALSE if child number is not 1" do
          prepare_and_take_survey(nil, nil,
                                  :create_participant_verif_m_3_0) do |r|
            r.a "PARTICIPANT_VERIF.CHILD_QNUM", 'number', :value => 2
          end
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_child_qnum_one").should == "FALSE"
        end

        it "should be FALSE if child number is not set" do
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_child_qnum_one").should == "FALSE"
        end
      end

      describe "prepopulated_is_multiple_child" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_6Month_INT_EHPBHIPBS_M3.1_V2.0_PART_TWO",
                      "prepopulated_is_multiple_child")
          init_common_vars
        end

        it "should be TRUE if more then one child is eligible for interview" do
          prepare_and_take_survey("PARTICIPANT_VERIF.MULT_CHILD", NcsCode::YES,
                                  :create_participant_verif_m_3_0)
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_multiple_child").should == "TRUE"
        end

        it "should be FALSE if only one child is eligible for interview" do
          prepare_and_take_survey("PARTICIPANT_VERIF.MULT_CHILD", NcsCode::NO,
                                  :create_participant_verif_m_3_0)
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_multiple_child").should == "FALSE"
        end

        it "should be FALSE if number of elgible children is not known" do
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_multiple_child").should == "FALSE"
        end
      end

    context "for 6Month part one prepopulators"
      describe "prepopulated_is_three_months_interview_set_to_complete" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                "INS_QUE_6Month_INT_EHPBHIPBS_M3.1_V2.0_SIX_MTH_MOTHER_DETAIL",
                "prepopulated_is_three_months_interview_set_to_complete")
          init_common_vars
        end

        it "should be TRUE if 3-month interview event was completed" do
          make_contact(Event::three_month_visit_code)
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_is_three_months_interview_set_to_complete"
                ).should == "TRUE"
        end

        it "should be FALSE if 3-month interview event was not completed" do
          make_contact(Event::three_month_visit_code, event_complete = false)
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_is_three_months_interview_set_to_complete"
                ).should == "FALSE"
        end

        it "should be FALSE if 3-month interview event never happened" do
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_is_three_months_interview_set_to_complete"
                ).should == "FALSE"
        end
      end

    context "for 6MM mother detail prepopulators"
      describe "prepopulated_mult_child_answer_from_part_one_for_6MM" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_6MMother_INT_EHPBHI_P2_V11_SIX_MTH_MOTHER_DETAIL",
                      "prepopulated_mult_child_answer_from_part_one_for_6MM")
          init_common_vars
        end

        it "should be TRUE when answer to MULT_CHILD from part one is YES" do
          prepare_and_take_survey("SIX_MTH_MOTHER.MULT_CHILD", NcsCode::YES,
                                  :create_6mm_part_one_mult_child)
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_mult_child_answer_from_part_one_for_6MM"
                ).should == "TRUE"
        end

        it "should be FALSE when answer to MULT_CHILD from part one is NO" do
          prepare_and_take_survey("SIX_MTH_MOTHER.MULT_CHILD", NcsCode::NO,
                                  :create_6mm_part_one_mult_child)
          run_populator
          get_response_as_string(@response_set,
                  "prepopulated_mult_child_answer_from_part_one_for_6MM"
                ).should == "FALSE"
        end

        it "should be TRUE when there's no answer to MULT_CHILD from part one" do
          run_populator
          get_response_as_string(@response_set,
                        "prepopulated_mult_child_answer_from_part_one_for_6MM"
                ).should == "FALSE"
        end
      end

    context "for 3MM child habits prepopulators"
      describe "prepopulated_is_birth_deliver_collected_and_set_to_one" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_3Month_INT_EHPBHILIPBS_M3.1_V2.0_CHILD_HABITS",
                      "prepopulated_is_birth_deliver_collected_and_set_to_one")
          init_common_vars
        end

        it "should be TRUE when a birth was given at a hospital" do
          prepare_and_take_survey('BIRTH_VISIT_LI_2.BIRTH_DELIVER',
                                  1, :create_birth_part_one_birth_deliver)
          run_populator
          get_response_as_string(@response_set,
            "prepopulated_is_birth_deliver_collected_and_set_to_one"
          ).should == "TRUE"
        end
        it "should be FALSE when a birth was not given at a hospital" do
          prepare_and_take_survey('BIRTH_VISIT_LI_2.BIRTH_DELIVER',
                                  2, :create_birth_part_one_birth_deliver)
          run_populator
          get_response_as_string(@response_set,
            "prepopulated_is_birth_deliver_collected_and_set_to_one"
          ).should == "FALSE"
        end
        it "should be FALSE when information about birth was not collected" do
          run_populator
          get_response_as_string(@response_set,
            "prepopulated_is_birth_deliver_collected_and_set_to_one"
          ).should == "FALSE"
        end
      end

      describe "prepopulated_is_prev_event_birth_li_and_set_to_complete" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_3Month_INT_EHPBHILIPBS_M3.1_V2.0_CHILD_HABITS",
                      "prepopulated_is_prev_event_birth_li_and_set_to_complete")
          init_common_vars
        end

        it "should be TRUE when last is an incomplete birth record" do
          make_contact(Event::birth_code, event_complete = false)
          run_populator
          get_response_as_string(@response_set,
            "prepopulated_is_prev_event_birth_li_and_set_to_complete"
          ).should == "TRUE"
        end

        it "should be TRUE when no birth record exists" do
          run_populator
          get_response_as_string(@response_set,
            "prepopulated_is_prev_event_birth_li_and_set_to_complete"
          ).should == "TRUE"
        end

        it "should be FALSE when last is a complete birth record" do
          make_contact(Event::birth_code)
          run_populator
          get_response_as_string(@response_set,
            "prepopulated_is_prev_event_birth_li_and_set_to_complete"
          ).should == "FALSE"
        end

        it "should be TRUE when last is an incomplete birth record when multiple births" do
          e = make_contact(Event::birth_code)
          e.event_start_date = '2010-12-01'
          e.save!
          e = make_contact(Event::birth_code, event_complete = false)
          e.event_start_date = '2011-12-01'
          e.save!
          run_populator
          get_response_as_string(@response_set,
                "prepopulated_is_prev_event_birth_li_and_set_to_complete"
          ).should == "TRUE"
        end

        it "should be FALSE when last is a complete birth record when multiple births" do
          e = make_contact(Event::birth_code, event_complete = false)
          e.event_start_date = '2010-12-01'
          e.save!
          e = make_contact(Event::birth_code)
          e.event_start_date = '2011-12-01'
          e.save!
          run_populator
          get_response_as_string(@response_set,
                "prepopulated_is_prev_event_birth_li_and_set_to_complete"
          ).should == "FALSE"
        end

      end

      describe "prepopulated_is_multiple_child" do
        def have_children(quantity)
          mother = @participant
          child_code = NcsCode::for_list_name_and_display_text(
                                          "PERSON_PARTCPNT_RELTNSHP_CL1",
                                          "Child").local_code
          mother_code = NcsCode::for_list_name_and_display_text(
                                          "PERSON_PARTCPNT_RELTNSHP_CL1",
                                          "Biological Mother").local_code
          (1..quantity).each do
            child = Factory(:participant)
            child.person = Factory(:person)
            ParticipantPersonLink.create(:person_id => child.person.id,
                                        :participant_id => mother.id,
                                        :relationship_code => child_code)
            ParticipantPersonLink.create(:person_id => mother.person.id,
                                        :participant_id => child.id,
                                        :relationship_code => mother_code)
            child.save!
          end
        end

        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_3Month_INT_EHPBHILIPBS_M3.1_V2.0_CHILD_HABITS",
                      "prepopulated_is_multiple_child")
          init_common_vars
        end

        it "should be TRUE when participant has multiple children" do
          have_children(2)
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_multiple_child").should == "TRUE"
        end

        it "should be FALSE when participant has only one child" do
          have_children(1)
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_multiple_child").should == "FALSE"
        end

        it "should be TRUE when participant has no children" do
          run_populator
          get_response_as_string(@response_set,
                            "prepopulated_is_multiple_child").should == "FALSE"
        end
      end

    context "for 3MM part two prepopulators"
      describe "prepopulated_is_6_month_event" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
                      "INS_QUE_3MMother_INT_EHPBHI_P2_V1.1_PART_TWO",
                      "prepopulated_should_show_demographics")
          init_common_vars
        end

        it "should be TRUE when there are no pre-natal events" do
          make_contact(Event::six_month_visit_code)
          run_populator
          get_response_as_string(@response_set,
                       "prepopulated_should_show_demographics").should == "TRUE"
        end

        it "should be FALSE when there are pre-natal events" do
          make_contact(Event::pregnancy_visit_1_code)
          run_populator
          get_response_as_string(@response_set,
                       "prepopulated_should_show_demographics").should == "FALSE"
        end
      end

    context "for 18MM v2.x prepopulators"
      describe "prepopulated_should_show_upper_arm_length" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
              "INS_QUE_18MMother_INT_EHPBHI_M2.2_V2.0_EIGHTEEN_MTH_MOTHER_MOLD",
              "prepopulated_should_show_room_mold_child")
          init_common_vars
        end

        it "should be TRUE if response to MOLD question was YES" do
          prepare_and_take_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", 1,
                      :create_18mm_v2_survey_part_three_for_mold_prepopulators)
          run_populator
          get_response_as_string(@response_set,
                        "prepopulated_should_show_room_mold_child"
                      ).should == "TRUE"
        end
        it "should be FALSE if response to MOLD question was NO" do
          prepare_and_take_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", 2,
                      :create_18mm_v2_survey_part_three_for_mold_prepopulators)
          run_populator
          get_response_as_string(@response_set,
                        "prepopulated_should_show_room_mold_child"
                      ).should == "FALSE"
        end

        it "should be FALSE if response to MOLD question was REFUSED" do
          prepare_and_take_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", "neg_1",
                      :create_18mm_v2_survey_part_three_for_mold_prepopulators)
          run_populator
          get_response_as_string(@response_set,
                        "prepopulated_should_show_room_mold_child"
                      ).should == "FALSE"
        end
        it "should be FALSE if response to MOLD question was REFUSED" do
          prepare_and_take_survey("EIGHTEEN_MTH_MOTHER_2.MOLD", "neg_2",
                      :create_18mm_v2_survey_part_three_for_mold_prepopulators)
          run_populator
          get_response_as_string(@response_set,
                        "prepopulated_should_show_room_mold_child"
                      ).should == "FALSE"
        end
        it "should be FALSE if 18MM part 3 survey was not completed" do
          run_populator
          get_response_as_string(@response_set,
                        "prepopulated_should_show_room_mold_child"
                      ).should == "FALSE"
        end
      end

    context "for 30M M3.1 prepopulators"
      describe "prepopulated_is_child_num_gt_or_eq_one_for_first_child" do
        before(:each) do
          @survey = create_generic_true_false_prepopulator_survey(
              "INS_QUE_30Month_INT_EHPBHILIPBS_M3.1_V1.0_CHILD",
              "prepopulated_is_child_num_gt_or_eq_one_for_first_child")
          init_common_vars
        end

        it "should be TRUE if there is only one child" do
          prepare_and_take_survey(nil, nil, :create_participant_verif_m_3_0
                                                                      ) do |r|
            r.no 'PARTICIPANT_VERIF.MULT_CHILD'
          end
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_is_child_num_gt_or_eq_one_for_first_child"
                      ).should == "TRUE"
        end
        it "should be TRUE if there are many children but our target is #1" do
          prepare_and_take_survey(nil, nil, :create_participant_verif_m_3_0
                                                                      ) do |r|
            r.yes 'PARTICIPANT_VERIF.MULT_CHILD'
            r.a 'PARTICIPANT_VERIF.CHILD_QNUM', 'number', :value => 1
          end
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_is_child_num_gt_or_eq_one_for_first_child"
                      ).should == "TRUE"
        end
        it "should be FALSE if there are many children but our target is #2" do
          prepare_and_take_survey(nil, nil, :create_participant_verif_m_3_0
                                                                      ) do |r|
            r.yes 'PARTICIPANT_VERIF.MULT_CHILD'
            r.a 'PARTICIPANT_VERIF.CHILD_QNUM', 'number', :value => 2
          end
          run_populator
          get_response_as_string(@response_set,
                      "prepopulated_is_child_num_gt_or_eq_one_for_first_child"
                      ).should == "FALSE"
        end
      end

      describe "prepopulated_intro_30_months" do
        before(:each) do
          @survey = part2_30_month_survey_M31
          init_common_vars
        end

        it "returns continue if that's the answer to INTRO_30MO" do
          prepare_and_take_survey("THIRTY_MONTH_INTERVIEW_CHILD.INTRO_30MO",
                                  1, :child_30_month_survey_M31)
          run_populator
          get_response_as_string(@response_set, "prepopulated_intro_30_months"
                                ).should == "CONTINUE"
        end
        it "returns REFUSED if that's the answer to INTRO_30MO" do
          prepare_and_take_survey("THIRTY_MONTH_INTERVIEW_CHILD.INTRO_30MO",
                                  "neg_1", :child_30_month_survey_M31)
          run_populator
          get_response_as_string(@response_set, "prepopulated_intro_30_months"
                                ).should == "REFUSED"
        end
      end

  end
end
