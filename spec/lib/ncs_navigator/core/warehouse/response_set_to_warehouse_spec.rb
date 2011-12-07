# -*- coding: utf-8 -*-
require 'spec_helper'

require 'ncs_navigator/core/warehouse/response_set_to_warehouse'

module NcsNavigator::Core::Warehouse
  describe ResponseSetToWarehouse do
    it 'is mixed into ResponseSet' do
      ::ResponseSet.ancestors.should include(ResponseSetToWarehouse)
    end

    let(:questions_dsl) {
      <<-DSL
      q_health "Would you say your health in general is...",
        :pick=>:one,
        :data_export_identifier=>"PRE_PREG.HEALTH"
        a_1 "Excellent"
        a_2 "Very good,"
        a_3 "Good,"
        a_4 "Fair, or"
        a_5 "Poor?"
        a_neg_1 "Refused"
        a_neg_2 "Don't know"
      DSL
    }
    let(:survey) {
      load_survey_string(<<-SURVEY)
survey "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1" do
  section "Interview introduction" do
    #{questions_dsl}
  end
end
      SURVEY
    }
    let(:questions) { survey.sections_with_questions.collect(&:questions).flatten }
    let(:questions_map) { questions.inject({}) { |h, q| h[q.reference_identifier] = q; h } }

    let(:participant) { Factory(:participant) }
    let(:event) { Factory(:event, :participant => participant) }
    let(:instrument) { Factory(:instrument, :event => event) }
    let(:response_set) { ResponseSet.create(:survey => survey, :instrument => instrument) }

    let(:records) { response_set.to_mdes_warehouse_records }

    def create_response_for(question)
      response_set.responses.build(:question => question).tap { |r|
        yield r
        r.save!
      }
    end

    before do
      Survey.mdes_reset!
    end

    context 'external references' do
      let(:primary) { records.find { |rec| rec.class.mdes_table_name == 'pre_preg' } }
      let(:question) { questions_map['health'] }

      before do
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text('Excellent')
        }
      end

      it "has a primary key based on the response set access code" do
        response_set.access_code.should_not be_nil # test setup
        primary.key.first.should include(response_set.access_code)
      end

      it 'uses the public ID for the associated event' do
        primary.event_id.should == event.public_id
      end

      it 'uses the event type from the associated event' do
        event.event_type_code.should_not be_nil # test setup
        primary.event_type.should == event.event_type_code.to_s
      end

      it 'uses the event repeat from the associated event' do
        event.update_attribute(:event_repeat_key, 3)
        primary.event_repeat_key.should == '3'
      end

      it 'uses the public ID for the associated instrument' do
        primary.instrument_id.should == instrument.public_id
      end

      it 'uses the instrument repeat from the associated instrument' do
        instrument.update_attribute(:instrument_repeat_key, 2)
        primary.instrument_repeat_key.should == '2'
      end

      it 'uses the instrument version from the associated instrument' do
        instrument.instrument_version.should_not be_nil # test setup
        primary.instrument_version.should == instrument.instrument_version
      end

      it 'uses the public ID for the associated participant' do
        primary.p_id.should == participant.public_id
      end

      it 'uses the public ID for the dwelling unit' do
        pending 'Is this necessary? Documentation scarce.'
      end

      it 'uses the public ID for the household unit' do
        pending 'Needs a different instrument'
      end
    end

    describe 'with a purely coded question' do
      let(:question) { questions_map['health'] }

      it 'sets a positive code correctly' do
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text('Poor?')
        }

        records.first.health.should == '5'
      end

      it 'sets a negative code correctly' do
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text('Refused')
        }

        records.first.health.should == '-1'
      end
    end

    describe 'with a code-or-text question' do
      let(:question) { questions_map['r_fname'] }

      let(:questions_dsl) {
        <<-DSL
          q_r_fname "First name",
          :pick=>:one,
          :data_export_identifier=>"PRE_PREG.R_FNAME"
          a :string
          a_neg_1 "Refused"
          a_neg_2 "Don't know"
        DSL
      }

      it 'uses the text if set' do
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_response_class('string')
          r.string_value = 'Linda'
        }

        records.first.r_fname.should == 'Linda'
      end

      it 'uses the coded value if set' do
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text("Don't know")
        }

        records.first.r_fname.should == '-2'
      end
    end

    describe 'with a multivalued question' do
      let(:questions_dsl) {
        <<-DSL
          q_PERSON_DOB "What is your date of birth?",
          :help_text => "If participant refuses to provide information, re-state confidentiality protections and that dob
          is required to determine eligibility. If response was determined to be invalid, ask question again and probe for
          valid response. Verify if calculated age is less than local age of majority.",
          :pick => :one,
          :data_export_identifier=>"FATHER_PV1.PERSON_DOB"
          a "Date", :string, :custom_class => "date"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"

          q_EDUC "What is the highest degree or level of school that you have completed?",
          :help_text => "Show response options on card to participant. Select all that apply.",
          :pick => :any,
          :data_export_identifier=>"FATHER_PV1_EDUC.EDUC"
          a_1 "Less than a high school diploma or GED"
          a_2 "High school diploma or GED"
          a_3 "Some college but no degree"
          a_4 "Associate degree"
          a_5 "Bachelor’s degree (e.g., BA, BS)"
          a_6 "Post graduate degree (e.g., Masters or Doctoral)"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"
        DSL
      }

      let(:primary_question) { questions_map['PERSON_DOB'] }
      let(:question) { questions_map['EDUC'] }

      let(:primary) { records.detect { |r| r.class.mdes_table_name == 'father_pv1' } }
      let(:secondary) { records.select { |r| r.class.mdes_table_name == 'father_pv1_educ' } }

      before do
        create_response_for(primary_question) { |r|
          r.answer = primary_question.answers.find_by_response_class('string')
          r.string_value = '1967-04-07'
        }
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text("High school diploma or GED") or fail
        }
        create_response_for(question) { |r|
          r.answer = question.answers.
            find_by_text("Post graduate degree (e.g., Masters or Doctoral)") or fail
        }
      end

      it 'produces one record per answered question' do
        secondary.size.should == 2
      end

      it 'codes the multiple records correctly' do
        secondary.collect(&:educ).sort.should == %w(2 6)
      end

      it 'associates the subrecords with the parent' do
        primary.key.should_not be_nil
        secondary.collect(&:father_id).uniq.should == [primary.key.first]
      end

      it 'gives each subrecord a unique ID' do
        secondary.collect(&:father_educ_id).uniq.size.should == 2
      end
    end

    describe 'with a multivalued question with an "other" option' do
      let(:questions_dsl) {
        <<-DSL
          q_RENOVATE "In the last 6 months, have any additions been built onto your home to make it bigger or renovations or other
          construction been done in your home? Include only major projects. Do not count smaller projects, such as painting, wallpapering,
          carpeting or re-finishing floors.",
          :pick => :one,
          :data_export_identifier=>"TWELVE_MTH_MOTHER.RENOVATE"
          a_1 "Yes"
          a_2 "No"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"

          q_RENOVATE_ROOM "Which rooms were renovated?",
          :help_text => "Probe: Any others? Select all that apply.",
          :pick => :any,
          :data_export_identifier=>"TWELVE_MTH_MOTHER_RENOVATE_ROOM.RENOVATE_ROOM"
          a_1 "Kitchen"
          a_2 "Living room"
          a_3 "Hall/landing"
          a_4 "{C_FNAME}’s bedroom"
          a_5 "Other bedroom"
          a_6 "Bathroom/toilet"
          a_7 "Basement"
          a_neg_5 "Other"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"

          q_RENOVATE_ROOM_OTH "Other room",
          :pick => :one,
          :data_export_identifier=>"TWELVE_MTH_MOTHER_RENOVATE_ROOM.RENOVATE_ROOM_OTH"
          a "Specify", :string
          a_neg_1 "Refused"
          a_neg_2 "Don't know"
        DSL
      }

      let(:primary_question) { questions_map['RENOVATE'] }
      let(:question) { questions_map['RENOVATE_ROOM'] }
      let(:other) { questions_map['RENOVATE_ROOM_OTH'] }

      let(:primary) { records.detect { |r| r.class.mdes_table_name == 'twelve_mth_mother' } }
      let(:secondary) {
        records.select { |r| r.class.mdes_table_name == 'twelve_mth_mother_renovate_room' }
      }

      before do
        create_response_for(primary_question) { |r|
          r.answer = primary_question.answers.find_by_text("Yes") or fail
        }

        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text("Kitchen") or fail
        }
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text("Other") or fail
        }
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text("Other bedroom") or fail
        }
        create_response_for(question) { |r|
          r.answer = question.answers.find_by_text("Don't know") or fail
        }
        create_response_for(other) { |r|
          r.answer = other.answers.find_by_response_class('string') or fail
          r.string_value = 'Carriage house'
        }
      end

      it 'records the other answer in the same record as the other value' do
        secondary.find { |rec| rec.renovate_room == '-5' }.
          renovate_room_oth.should == 'Carriage house'
      end

      it 'does not record the other answer in any of the other responses' do
        secondary.reject { |rec| rec.renovate_room == '-5' }.each do |rec|
          rec.renovate_room_oth.should be_nil
        end
      end

      it 'records multiple coded values as separate records' do
        secondary.collect(&:renovate_room).sort.should == %w(-2 -5 1 5)
      end
    end

    describe 'with a fixed value' do
      let(:questions_dsl) {
        <<-DSL
          q_COLLECTION_STATUS "Blood tube collection overall status",
          :pick => :one,
          :data_export_identifier=>"SPEC_BLOOD.COLLECTION_STATUS"
          a_1 "Collected"
          a_2 "Partially collected"
          a_3 "Not collected"

          q_TUBE_STATUS_TUBE_TYPE_2_VISIT_1 "Blood tube collection status",
          :pick => :one,
          :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_STATUS"
          a_1 "Full draw"
          a_2 "Short draw"
          a_3 "No draw"

          q_TUBE_STATUS_TUBE_TYPE_3_VISIT_1 "Blood tube collection status",
          :pick => :one,
          :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_STATUS"
          a_1 "Full draw"
          a_2 "Short draw"
          a_3 "No draw"

          q_TUBE_COMMENTS_OTH_TUBE_TYPE_3_VISIT_1 "Blood tube collection other comments",
          :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=3].TUBE_COMMENTS_OTH"
          a_1 "Specify", :string
        DSL
      }

      let(:tubes) { records.select { |rec| rec.class.mdes_table_name == 'spec_blood_tube' } }

      before do
        create_response_for(questions_map['TUBE_STATUS_TUBE_TYPE_2_VISIT_1']) { |r|
          r.answer = r.question.answers.find_by_text("Full draw") or fail
        }
        create_response_for(questions_map['TUBE_STATUS_TUBE_TYPE_3_VISIT_1']) { |r|
          r.answer = r.question.answers.find_by_text("No draw") or fail
        }
        create_response_for(questions_map['TUBE_COMMENTS_OTH_TUBE_TYPE_3_VISIT_1']) { |r|
          r.answer = r.question.answers.find_by_response_class("string") or fail
          r.string_value = 'Scarring'
        }
      end

      it 'includes the fixed value in separate emitted records' do
        tubes.collect(&:tube_type).sort.should == %w(2 3)
      end

      it 'consolidates responses with the same fixed values into the same record' do
        tubes.collect { |t| [t.tube_status, t.tube_comments_oth] }.
          sort_by { |ts, tc| ts }.should == [ ['1', nil], ['3', 'Scarring'] ]
      end

      it 'works with tertiary tables' do
        pending '#1653'
      end
    end

    describe 'with a repeated subsection' do
      it 'works' do
        pending '#1656'
      end

      it 'works with tertiary associations' do
        pending '#1653'
      end
    end
  end
end

