# -*- coding: utf-8 -*-

require 'spec_helper'

require 'ncs_navigator/core/warehouse/instrument_to_warehouse'

module NcsNavigator::Core::Warehouse
  describe InstrumentToWarehouse, :warehouse do
    it 'is mixed into Instrument' do
      ::Instrument.ancestors.should include(InstrumentToWarehouse)
    end

    let(:wh_config) {
      NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.mdes_version = NcsNavigatorCore.mdes_version.number
      end
    }

    let(:mother_participant) { Factory(:participant, :p_id => 'MP') }
    let(:event) { Factory(:mdes_min_event, :participant => mother_participant) }
    let(:instrument) { Factory(:instrument, :event => event) }

    let(:records) { instrument.to_mdes_warehouse_records(wh_config) }

    def records_for(mdes_table_name)
      records.select { |rec| rec.class.mdes_table_name == mdes_table_name.downcase }
    end

    def create_response_for(question, response_set=response_set)
      response_set.responses.build(:question => question).tap { |r|
        yield r

        unless r.answer
          if r.string_value
            r.answer = r.question.answers.find_by_response_class('string')
          elsif r.integer_value
            r.answer = r.question.answers.find_by_response_class('integer')
          end
        end

        fail 'Answer is nil' unless r.answer
        r.save!
      }
    end

    before do
      Survey.mdes_reset!
    end

    describe 'for a single-survey instrument' do
      let(:questions_dsl) {
        <<-DSL
        q_hemophilia "Do you have hemophilia or any bleeding disorder?",
          :pick=>:one,
          :data_export_identifier=>"SPEC_BLOOD.HEMOPHILIA"
          a_1 "Yes"
          a_2 "No"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"
        DSL
      }
      let(:survey) {
        load_survey_questions_string(questions_dsl)
      }
      let(:questions) { survey.sections_with_questions.collect(&:questions).flatten }
      let(:questions_map) { questions.inject({}) { |h, q| h[q.reference_identifier] = q; h } }

      let(:rs_participant) { Factory(:participant) }
      let(:rs_person) { Factory(:person) }
      let(:dwelling_unit) { Factory(:dwelling_unit) }
      let(:household_unit) { Factory(:household_unit) }
      let!(:dwelling_household_link) {
        Factory(:dwelling_household_link,
                :dwelling_unit => dwelling_unit,
                :household_unit => household_unit
               )
      }
      let!(:household_person_link) {
        Factory(:household_person_link,
                :person => rs_person,
                :household_unit => household_unit
               )
      }
      let(:response_set) {
        ResponseSet.new.tap { |rs|
          rs.survey = survey
          rs.instrument = instrument
          rs.participant = rs_participant
          rs.person = rs_person
          rs.save!
        }
      }

      context 'external references' do
        let(:primary) { records.find { |rec| rec.class.mdes_table_name == 'spec_blood' } }
        let(:question) { questions_map['hemophilia'] }
        let!(:response) {
          create_response_for(question) { |r|
            r.answer = question.answers.find_by_text('Yes')
          }
        }

        it "has a primary key based on the response set access code" do
          response_set.access_code.should_not be_nil # test setup
          primary.key.first.should include(response_set.access_code)
        end

        it 'uses the imported ID as the PK if the responses were imported' do
          response.source_mdes_table = 'spec_blood'
          response.source_mdes_id = 'Eleventy-two'
          response.save!

          primary.key.first.should == 'Eleventy-two'
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

        it 'uses the instrument type from the associated instrument' do
          instrument.instrument_type.should_not be_nil # test setup
          primary.instrument_type.should == instrument.instrument_type_code.to_s
        end

        it 'uses the public ID for the participant associated with the response set' do
          primary.p_id.should == rs_participant.public_id
        end

        it 'uses the public ID for the dwelling unit' do
          primary.du_id.should == dwelling_unit.public_id
        end

        it 'uses the public ID for the household unit' do
          primary.hh_id.should == household_unit.public_id
        end

        context do
          # This setup assumes MDES 3.0 or greater
          let(:questions_dsl) {
            <<-DSL
              q_ADDRESS_1 "ADDRESS 1 - STREET/PO BOX",
              :pick=>:one,
              :data_export_identifier=>"PBS_ELIG_SCREENER.ADDRESS_1"
              a :string
              a_neg_1 "REFUSED"
              a_neg_2 "DON'T KNOW"
            DSL
          }
          let(:primary) { records.find { |rec| rec.class.mdes_table_name == 'pbs_elig_screener' } }
          let(:question) { questions_map['ADDRESS_1'] }
          let!(:response) {
            create_response_for(question) { |r|
              r.answer = question.answers.find_by_text('REFUSED')
            }
          }

          it 'uses the public ID for the person' do
            primary.person_id.should == rs_person.public_id
          end

          describe 'when there is a participant' do
            it "uses that participant's PPG_FIRST if she has one" do
              rs_participant.ppg_details.clear.build(:ppg_first_code => 3)
              rs_participant.save!

              primary.ppg_first.should == '3'
            end

            it "uses -4 for PPG_FIRST if the participant has no PPG_FIRST" do
              primary.ppg_first.should == '-4'
            end
          end

          describe 'when there is no participant' do
            before do
              response_set.participant = nil
              response_set.save!
            end

            it 'uses -4 for PPG_FIRST' do
              primary.ppg_first.should == '-4'
            end
          end
        end
      end

      describe 'with a purely coded question' do
        let(:question) { questions_map['hemophilia'] }

        it 'sets a positive code correctly' do
          create_response_for(question) { |r|
            r.answer = question.answers.find_by_text('No')
          }

          records.first.hemophilia.should == '2'
        end

        it 'sets a negative code correctly' do
          create_response_for(question) { |r|
            r.answer = question.answers.find_by_text('Refused')
          }

          records.first.hemophilia.should == '-1'
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
          create_response_for(question) { |r|
            r.answer = question.answers.find_by_text("High school diploma or GED") or fail
          }
          create_response_for(question) { |r|
            r.answer = question.answers.
              find_by_text("Post graduate degree (e.g., Masters or Doctoral)") or fail
          }
          create_response_for(primary_question) { |r|
            r.answer = primary_question.answers.find_by_response_class('string')
            r.string_value = '1967-04-07'
          }
        end

        it 'yields the primary record first' do
          records.collect { |r| r.class.mdes_table_name }.
            should == %w(father_pv1 father_pv1_educ father_pv1_educ)
        end

        it 'produces one record per answered question' do
          secondary.size.should == 2
        end

        it 'codes the multiple records correctly' do
          secondary.collect(&:educ).sort.should == %w(2 6)
        end

        it 'associates the subrecords with the parent ID' do
          primary.key.should_not be_nil
          secondary.collect(&:father_id).uniq.should == [primary.key.first]
        end

        it 'associates the subrecords with the parent instance' do
          primary.key.should_not be_nil
          secondary.collect(&:father).uniq.should == [primary]
        end

        it 'gives each subrecord a unique ID' do
          secondary.collect(&:father_educ_id).uniq.size.should == 2
        end

        it 'reuses the imported IDs if the responses were imported' do
          Response.find_all_by_question_id(question).each_with_index do |r, i|
            r.source_mdes_table = 'father_pv1_educ'
            r.source_mdes_id = i.to_s * 4
            r.save!
          end

          secondary.collect(&:father_educ_id).sort.should == %w(0000 1111)
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
        end

        describe 'when multiple options are selected' do
          before do
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

        describe 'when only the other option is selected' do
          before do
            create_response_for(question) { |r|
              r.answer = question.answers.find_by_text("Other") or fail
            }
            create_response_for(other) { |r|
              r.answer = other.answers.find_by_response_class('string') or fail
              r.string_value = 'Carriage house'
            }
          end

          it 'produces only one record' do
            secondary.collect(&:renovate_room).should == %w(-5)
          end

          it 'records the other answer in the same record as the other value' do
            secondary.first.renovate_room_oth.should == 'Carriage house'
          end
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
      end

      describe 'with fixed values and a tertiary table' do
        let(:questions_dsl) {
          <<-DSL
            q_COLLECTION_STATUS "Blood tube collection overall status",
            :pick => :one,
            :data_export_identifier=>"SPEC_BLOOD.COLLECTION_STATUS"
            a_1 "Collected"
            a_2 "Partially collected"
            a_3 "Not collected"

            q_SPECIMEN_ID_TUBE_TYPE_1_VISIT_1 "Tube barcode",
            :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].SPECIMEN_ID"
            a "AA|-SS10", :string

            q_TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1 "Blood tube collection comments",
            :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply",
            :pick => :any,
            :data_export_identifier=>"SPEC_BLOOD_TUBE_COMMENTS[tube_type=1].TUBE_COMMENTS"
            a_1 "Equipment failure"
            a_2 "Fainting"
            a_3 "Light-headedness"
            a_4 "Hematoma"
            a_5 "Bruising"
            a_6 "Vein collapsed during procedure"
            a_7 "No suitable vein"
            a_neg_5 "Other"
            a_neg_1 "Refused"
            a_neg_2 "Don’t know"

            q_TUBE_COMMENTS_OTH_TUBE_TYPE_1_VISIT_1 "Blood tube collection other comments",
            :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=1].TUBE_COMMENTS_OTH"
            a_1 "Specify", :string

            q_SPECIMEN_ID_TUBE_TYPE_2_VISIT_1 "Tube barcode",
            :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].SPECIMEN_ID"
            a "AA|-RD10", :string

            q_TUBE_COMMENTS_TUBE_TYPE_2_VISIT_1 "Blood tube collection comments",
            :help_text => "Enter reasons tube_type was not collected or draw was short. Select all that apply",
            :pick => :any,
            :data_export_identifier=>"SPEC_BLOOD_TUBE_COMMENTS[tube_type=2].TUBE_COMMENTS"
            a_1 "Equipment failure"
            a_2 "Fainting"
            a_3 "Light-headedness"
            a_4 "Hematoma"
            a_5 "Bruising"
            a_6 "Vein collapsed during procedure"
            a_7 "No suitable vein"
            a_neg_5 "Other"
            a_neg_1 "Refused"
            a_neg_2 "Don’t know"

            q_TUBE_COMMENTS_OTH_TUBE_TYPE_2_VISIT_1 "Blood tube collection other comments",
            :data_export_identifier=>"SPEC_BLOOD_TUBE[tube_type=2].TUBE_COMMENTS_OTH"
            a_1 "Specify", :string
            dependency :rule=>"A"
          DSL
        }

        let(:blood_record)         { records_for('spec_blood').first }
        let(:tube_records)         { records_for('spec_blood_tube') }
        let(:tube_comment_records) { records_for('spec_blood_tube_comments') }

        before do
          create_response_for(questions_map['COLLECTION_STATUS']) do |r|
            r.answer = r.question.answers.find_by_text("Partially collected") or fail
          end

          create_response_for(questions_map['SPECIMEN_ID_TUBE_TYPE_1_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_response_class("string") or fail
            r.string_value = '42-1'
          end
          create_response_for(questions_map['TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_text("Fainting") or fail
            r.response_group = 1
          end
          create_response_for(questions_map['TUBE_COMMENTS_TUBE_TYPE_1_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_text("Other") or fail
            r.response_group = 2
          end
          create_response_for(questions_map['TUBE_COMMENTS_OTH_TUBE_TYPE_1_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_response_class("string") or fail
            r.string_value = 'Bindlery'
          end

          create_response_for(questions_map['SPECIMEN_ID_TUBE_TYPE_2_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_response_class("string") or fail
            r.string_value = '42-2'
          end
          create_response_for(questions_map['TUBE_COMMENTS_TUBE_TYPE_2_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_text("Bruising") or fail
            r.response_group = 1
          end
          create_response_for(questions_map['TUBE_COMMENTS_TUBE_TYPE_2_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_text("Refused") or fail
            r.response_group = 2
          end
          create_response_for(questions_map['TUBE_COMMENTS_OTH_TUBE_TYPE_2_VISIT_1']) do |r|
            r.answer = r.question.answers.find_by_response_class("string") or fail
            r.string_value = 'Scarring'
          end
        end

        it 'collates secondary responses with the same fixed value' do
          tube_records.collect { |rec| [rec.specimen_id, rec.tube_comments_oth] }.sort.should == [
            ['42-1', 'Bindlery'],
            ['42-2', 'Scarring']
          ]
        end

        it 'associates the secondary records with the primary record' do
          tube_records.collect(&:spec_blood_id).uniq.should == [blood_record.spec_blood_id]
        end

        it 'associates the tertiary records with the appropriate secondary records' do
          tube_ids_by_type_id = tube_records.inject({}) { |map, rec| map[rec.tube_type] = rec; map }

          tube_comment_records.inject({}) { |map, ter_rec|
            ((map[ter_rec.spec_blood_tube_id] ||= []) << ter_rec.tube_comments).sort!; map
          }.should == {
            tube_ids_by_type_id['1'].key.first => %w(-5 2),
            tube_ids_by_type_id['2'].key.first => %w(-1 5)
          }
        end
      end

      describe 'with skippable questions' do
        let(:questions_dsl) {
          <<-DSL
            q_OUT_TALK "Is there a better time when we could talk?",
            :pick => :one,
            :data_export_identifier=>"LOW_HIGH_SCRIPT.OUT_TALK"
            a_1 "Yes"
            a_2 "No"
            a_neg_1 "Refused"
            a_neg_2 "Don’t know"

            group "Call setup" do
              dependency :rule => "A"
              condition_A :q_OUT_TALK, "==", :a_1

              q_R_BEST_TTC_1 "What would be a better time for you?",
              :help_text => "Enter in hour and minute values",
              :pick => :one,
              :data_export_identifier=>"LOW_HIGH_SCRIPT.R_BEST_TTC_1"
              a_time "Time", :string
              a_neg_1 "Refused"
              a_neg_2 "Don't know"

              q_DAY_WEEK_2 "What would be a good day to reach her?",
              :help_text => "Enter in day(s) of week",
              :pick => :one,
              :data_export_identifier=>"LOW_HIGH_SCRIPT.DAY_WEEK_2"
              a_days_of_week "Day(s) of the week", :string
              a_neg_1 "Refused"
              a_neg_2 "Don't know"

              q_R_BEST_TTC_2 "Select AM or PM",
              :pick => :one,
              :data_export_identifier=>"LOW_HIGH_SCRIPT.R_BEST_TTC_2"
              a_am "AM"
              a_pm "PM"
              a_neg_1 "Refused"
              a_neg_2 "Don't know"

              q_R_BEST_TTC_3 "Additional info",
              :pick => :one,
              :data_export_identifier=>"LOW_HIGH_SCRIPT.R_BEST_TTC_3"
              a_am "After time reported"
              a_pm "Before time reported"
              a_neg_1 "Refused"
              a_neg_2 "Don't know"

              q_R_BEST_TTC4 "Thank you. I will try again later.",
              :help_text => "End call and code case status."
            end

            q_FOLLOWUP_1 "Thank you for taking the time to answer these questions today. However, at this time, we are only
            making visits to women who are pregnant or who are trying to get pregnant. Based on what I thought I heard you say,
            I understand that you are not pregnant or trying to get pregnant at this time. Is this correct?",
            :help_text => "You may say [I’m sorry to hear you’ve lost your baby – I know this can be a hard time.]
            if social cues indicate it is appropriate.",
            :pick => :one,
            :data_export_identifier=>"LOW_HIGH_SCRIPT.FOLLOWUP_1"
            a_1 "Yes (not pregnant, not trying)"
            a_2 "No (SP is trying)"
            a_3 "No (SP is pregnant)"
            a_neg_1 "Refused"
            a_neg_2 "Don’t know"
            # non-MDES dep for testing
            dependency :rule => "A"
            condition_A :q_OUT_TALK, "==", :a_1
          DSL
        }

        let(:out_talk) { questions_map['OUT_TALK'] }

        let(:record) { records.find { |rec| rec.class.mdes_table_name == 'low_high_script' } }

        context 'when legitimately skipped' do
          before do
            create_response_for(out_talk) { |r|
              r.answer = out_talk.answers.detect { |a| a.reference_identifier == '2' }
            }
          end

          it 'sets no value for a non-required field' do
            record.day_week_2.should be_nil
          end

          it 'sets the legitimate skip code for a required field' do
            record.r_best_ttc_2.should == '-3'
          end

          it 'sets the missing code if the skip code is not allowed' do
            record.followup_1.should == '-4'
          end
        end

        context 'when missed' do
          before do
            create_response_for(out_talk) { |r|
              r.answer = out_talk.answers.detect { |a| a.reference_identifier == '1' }
            }
          end

          it 'sets no value for a non-required field' do
            record.day_week_2.should be_nil
          end

          it 'sets the missing code for a required field' do
            record.r_best_ttc_2.should == '-4'
          end
        end
      end

      describe 'with a response to a non-exported question' do
        let(:questions_dsl) {
          <<-DSL
            q_extra_info "Some comments"
            a_1 'comments', :string

            q_annotated "Blood tube collection overall status",
            :pick => :one,
            :data_export_identifier=>"SPEC_BLOOD.COLLECTION_STATUS"
            a_1 "Collected"
            a_2 "Partially collected"
            a_3 "Not collected"
          DSL
        }

        let(:annotated_q)  { questions_map['annotated'] }
        let(:extra_info_q) { questions_map['extra_info'] }

        let(:record) { records.find { |rec| rec.class.mdes_table_name == 'spec_blood' } }

        before do
          create_response_for(annotated_q) { |r|
            r.answer = annotated_q.answers.detect { |a| a.reference_identifier == '2' }
          }

          create_response_for(extra_info_q) { |r|
            r.answer = extra_info_q.answers.first
            r.string_value = 'foo'
          }
        end

        it 'records the annotated question answer without error' do
          record.collection_status.should == '2'
        end
      end

      describe 'coding in date and time fields' do
        include NcsNavigator::Core::Surveyor::SurveyTaker

        let(:primary) { records.find { |rec| rec.class.mdes_table_name == 'spec_blood_2' } }
        let(:questions_dsl) {
          <<-DSL
            q_TIME_STAMP_2 "INSERT DATE/TIME STAMP", :data_export_identifier=>"SPEC_BLOOD_2.TIME_STAMP_2"
            a_timestamp :datetime, :custom_class => "datetime"

            q_LAST_DATE_EAT "LAST TIME ATE OR DRANK - DATE",
            :data_export_identifier=>"SPEC_BLOOD_2.LAST_DATE_EAT",
            :pick => :one
            a_date "DATE", :date, :custom_class => "date"
            a_neg_1 "REFUSED"
            a_neg_2 "DON'T KNOW"

            q_LAST_TIME_EAT "LAST TIME ATE OR DRANK - TIME",
            :pick => :one,
            :data_export_identifier=>"SPEC_BLOOD_2.LAST_TIME_EAT"
            a_time "HH:MM", :time, :custom_class => "12hr_time"
            a_neg_1 "REFUSED"
            a_neg_2 "DON'T KNOW"
          DSL
        }

        describe 'on time-formatted questions' do
          it 'passes HH:MM through' do
            respond(response_set) do |r|
              r.answer 'LAST_TIME_EAT', 'time', :value => '12:34'
            end

            response_set.save!

            primary.last_time_eat.should == '12:34'
          end

          it 'passes 12:92 through' do
            pending "Surveyor does not handle MDES date/time coding"

            respond(response_set) do |r|
              r.answer 'LAST_TIME_EAT', 'time', :value => '12:92'
            end

            response_set.save!

            primary.last_time_eat.should == '12:92'
          end

          it 'transforms -2 into 92:92' do
            respond(response_set) do |r|
              r.answer 'LAST_TIME_EAT', 'neg_2'
            end

            response_set.save!

            primary.last_time_eat.should == '92:92'
          end

          it 'transforms -1 into 91:91' do
            respond(response_set) do |r|
              r.answer 'LAST_TIME_EAT', 'neg_1'
            end

            response_set.save!

            primary.last_time_eat.should == '91:91'
          end
        end

        describe 'on date-formatted questions' do
          it 'passes YYYY-MM-DD through' do
            respond(response_set) do |r|
              r.answer 'LAST_DATE_EAT', 'date', :value => '2001-01-01'
            end

            response_set.save!

            primary.last_date_eat.should == '2001-01-01'
          end

          it 'passes 2009-01-92 through' do
            pending "Surveyor does not handle MDES date/time coding"

            respond(response_set) do |r|
              r.answer 'LAST_DATE_EAT', 'date', :value => '2009-01-92'
            end

            response_set.save!

            primary.last_date_eat.should == '2009-01-92'
          end

          it 'transforms -2 into 9222-92-92' do
            respond(response_set) do |r|
              r.answer 'LAST_DATE_EAT', 'neg_2'
            end

            response_set.save!

            primary.last_date_eat.should == '9222-92-92'
          end
        end

        it 'works for timestamp-formatted questions' do
          respond(response_set) do |r|
            r.answer 'TIME_STAMP_2', 'timestamp', :value => '2000-01-01T12:34:56'
          end

          response_set.save!

          primary.time_stamp_2.should == '2000-01-01T12:34:56'
        end
      end
    end

    describe 'for a multiple-survey instrument' do
      let(:child_participant_1) { Factory(:participant, :p_id => 'CP1') }
      let(:child_participant_2) { Factory(:participant, :p_id => 'CP2') }

      let(:mother_survey_part_one) {
        load_survey_questions_string(<<-QUESTIONS)
          q_CHILD_NUM "How many children in this household are eligible for the 3-month call today?",
          :data_export_identifier=>"THREE_MTH_MOTHER.CHILD_NUM"
          a_number "Number of children", :integer
        QUESTIONS
      }

      let(:mother_survey_part_two) {
        load_survey_questions_string(<<-QUESTIONS)
          q_ETHNICITY "Do you consider yourself to be Hispanic, or Latina?", :pick => :one,
          :data_export_identifier=>"THREE_MTH_MOTHER.ETHNICITY"
          a_1 "Yes"
          a_2 "No"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"

          q_RACE "What race do you consider yourself to be? You may select one or more.", :pick => :any,
          :data_export_identifier=>"THREE_MTH_MOTHER_RACE.RACE"
          a_1 "White,"
          a_2 "Black or African American,"
          a_3 "American Indian or Alaska Native"
          a_4 "Asian, or"
          a_5 "Native Hawaiian or Other Pacific Islander"
          a_6 "Multi Racial"
          a_neg_5 "Some other race?"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"
        QUESTIONS
      }

      let(:child_survey_detail) {
        load_survey_questions_string(<<-QUESTIONS)
          q_CHILD_QNUM "Which number child is this questionnaire for?",
          :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_DETAIL.CHILD_QNUM"
          a "Number", :integer
        QUESTIONS
      }

      let(:child_survey_habits) {
        load_survey_questions_string(<<-QUESTIONS)
          q_SLEEP_PLACE_2 "What does {{c_fname}} sleep in at night?", :pick => :one,
          :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_2"
          a_1 "A bassinette,"
          a_2 "A crib,"
          a_3 "A co-sleeper,"
          a_4 "In the bed or other place with you, or"
          a_neg_5 "In something else?"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"

          q_SLEEP_PLACE_2_OTH "Other sleeping arrangement", :pick => :one,
          :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.SLEEP_PLACE_2_OTH"
          a "Specify", :string
          a_neg_1 "Refused"
          a_neg_2 "Don't know"

          q_C_HEALTH "Since {{c_fname}} was born, would you say {{his_her}} health has been poor, fair, good, excellent?",
          :pick => :one,
          :data_export_identifier=>"THREE_MTH_MOTHER_CHILD_HABITS.C_HEALTH"
          a_1 "Poor"
          a_2 "Fair"
          a_3 "Good"
          a_4 "Excellent"
          a_neg_1 "Refused"
          a_neg_2 "Don't know"
        QUESTIONS
      }

      let(:surveys) { [mother_survey_part_one, mother_survey_part_two, child_survey_detail, child_survey_habits] }
      let(:questions) {
        surveys.collect { |survey| survey.sections_with_questions.collect(&:questions) }.flatten
      }
      let(:questions_map) { questions.inject({}) { |h, q| h[q.reference_identifier] = q; h } }

      def create_response_set(survey, participant)
        ResponseSet.new.tap { |rs|
          rs.survey = survey
          rs.participant_id = participant.id
          rs.instrument_id = instrument.id
          rs.save!
        }
      end

      let(:m_one_response_set) {
        create_response_set(mother_survey_part_one, mother_participant)
      }

      let(:m_two_response_set) {
        create_response_set(mother_survey_part_two, mother_participant)
      }

      let(:c1_detail_response_set) {
        create_response_set(child_survey_detail, child_participant_1)
      }

      let(:c1_habits_response_set) {
        create_response_set(child_survey_habits, child_participant_1)
      }

      let(:c2_detail_response_set) {
        create_response_set(child_survey_detail, child_participant_2)
      }

      let(:c2_habits_response_set) {
        create_response_set(child_survey_habits, child_participant_2)
      }

      describe 'external references' do
        let(:primary) { records.find { |rec| rec.class.mdes_table_name == 'three_mth_mother' } }
        let(:question) { questions_map['CHILD_NUM'] }
        let!(:response) {
          create_response_for(question, m_one_response_set) { |r|
            r.answer = question.answers.first
            r.integer_value = 2
          }
        }

        before do
          # ensure all response sets exist
          m_one_response_set; m_two_response_set
          c1_detail_response_set; c1_habits_response_set
          c2_detail_response_set; c2_habits_response_set
        end

        it "has a primary key based on the first response set's access code" do
          m_one_response_set.access_code.should_not be_nil # test setup
          primary.key.first.should include(m_one_response_set.access_code)
        end

        it 'uses the imported ID as the PK if the responses were imported' do
          response.source_mdes_table = 'three_mth_mother'
          response.source_mdes_id = 'Eleventy-two'
          response.save!

          primary.key.first.should == 'Eleventy-two'
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
          primary.instrument_repeat_key.should == 2
        end

        it 'uses the instrument version from the associated instrument' do
          instrument.instrument_version.should_not be_nil # test setup
          primary.instrument_version.should == instrument.instrument_version
        end

        it 'uses the instrument type from the associated instrument' do
          instrument.instrument_type.should_not be_nil # test setup
          primary.instrument_type.should == instrument.instrument_type_code.to_s
        end
      end

      describe 'for a table that is split across surveys' do
        let!(:m_one_response) {
          create_response_for(questions_map['CHILD_NUM'], m_one_response_set) do |r|
            r.answer = r.question.answers.first
            r.integer_value = 2
          end
        }

        let!(:m_two_response) {
          create_response_for(questions_map['ETHNICITY'], m_two_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Refused')
          end
        }

        let(:primaries) { records.select { |rec| rec.class.mdes_table_name == 'three_mth_mother' } }
        let(:primary) { primaries.first }

        describe 'when the response sets are for the same participant' do
          it 'consolidates all values' do
            primaries.size.should == 1
          end

          it 'incorporates the value from the first survey' do
            primary.child_num.should == '2'
          end

          it 'incorporates the values from the second survey' do
            primary.ethnicity.should == '-1'
          end

          it 'sets the participant for the record from the response set' do
            primary.p_id.should == mother_participant.p_id
          end
        end

        describe 'when the response sets are for different participants' do
          let(:another_mother) { Factory(:participant, :p_id => 'AMP') }

          before do
            m_two_response_set.participant = another_mother
            m_two_response_set.save!
          end

          it 'does not consolidate values' do
            primaries.size.should == 2
          end

          it 'sets the participant for the first record correctly' do
            rec = primaries.detect { |rec| rec.child_num == '2' }
            rec.p_id.should == mother_participant.p_id
          end

          it 'sets the participant for the second record correctly' do
            rec = primaries.detect { |rec| rec.ethnicity == '-1' }
            rec.p_id.should == another_mother.p_id
          end
        end
      end

      describe 'for multiple response sets for the same survey' do
        let!(:mother_num) {
          create_response_for(questions_map['CHILD_NUM'], m_one_response_set) do |r|
            r.answer = r.question.answers.first
            r.integer_value = 2
          end
        }

        let!(:c1_qnum) {
          create_response_for(questions_map['CHILD_QNUM'], c1_detail_response_set) do |r|
            r.answer = r.question.answers.first
            r.integer_value = 1
          end
        }

        let!(:c1_sleep_place) {
          create_response_for(questions_map['SLEEP_PLACE_2'], c1_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('A crib,')
          end
        }

        let!(:c1_health) {
          create_response_for(questions_map['C_HEALTH'], c1_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Good')
          end
        }

        let!(:c2_qnum) {
          create_response_for(questions_map['CHILD_QNUM'], c2_detail_response_set) do |r|
            r.answer = r.question.answers.first
            r.integer_value = 2
          end
        }

        let!(:c2_sleep_place) {
          create_response_for(questions_map['SLEEP_PLACE_2'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('In something else?')
          end
        }

        let!(:c2_sleep_place_oth) {
          create_response_for(questions_map['SLEEP_PLACE_2_OTH'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.first
            r.string_value = 'In the closet'
          end
        }

        let!(:c2_health) {
          create_response_for(questions_map['C_HEALTH'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Poor')
          end
        }

        let(:child_detail_records) {
          records.select { |rec| rec.class.mdes_table_name == 'three_mth_mother_child_detail'}
        }

        let(:child_habits_records) {
          records.select { |rec| rec.class.mdes_table_name == 'three_mth_mother_child_habits'}
        }

        let(:mother_record) { records.detect { |rec| rec.class.mdes_table_name == 'three_mth_mother' }}

        it 'creates separate records for each response set' do
          child_detail_records.size.should == 2
        end

        it 'gives each child record a unique ID' do
          child_detail_records.collect { |rec| rec.key.first }.uniq.size.should == 2
        end

        it 'associates the child records with the appropriate participants' do
          child_detail_records.inject({}) { |h, rec| h[rec.child_qnum] = rec.p_id; h }.should ==
            { '1' => child_participant_1.p_id, '2' => child_participant_2.p_id }
        end

        it 'associates the records to the parent' do
          mother_record.key.first.should_not be_nil

          child_detail_records.collect { |rec| rec.three_mth_id }.uniq.should == [ mother_record.key.first ]
        end

        it 'collates responses to the same survey' do
          child_habits_records.inject({}) { |h, rec|
            h[rec.p_id] = [rec.sleep_place_2, rec.sleep_place_2_oth, rec.c_health]; h
          }.should == {
            child_participant_1.p_id => [ '2', nil,             '3'],
            child_participant_2.p_id => ['-5', 'In the closet', '1']
          }
        end
      end

      describe 'with a multivalued question' do
        let(:mother_survey_part_one) {
          load_survey_questions_string(<<-QUESTIONS)
            q_CHILD_NUM "How many children of this mother are eligible for the 18 month visit today?",
            :help_text => "Enter number value",
            :data_export_identifier=>"EIGHTEEN_MTH_MOTHER.CHILD_NUM"
            a :integer
          QUESTIONS
        }

        let(:child_survey_habits) {
          load_survey_questions_string(<<-QUESTIONS)
            q_TV_FREQ_HRS "Over the past 30 days, on average, how many hours per day did {{c_fname}} sit and
            watch TV and/or DVDs? Would you say...",
            :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_HABITS.TV_FREQ_HRS",
            :pick => :one
            a_1 "Less than 1 hour,"
            a_2 "2 hours"
            a_3 "3 hours,"
            a_4 "4 hours,"
            a_5 "5 hours or more, or"
            a_6 "None, {{c_fname}} does not watch TV or DVDs"
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

            q_COND "During the past 3 months, has {{c_fname}} had any of the following conditions...",
            :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_COND.COND",
            :pick => :any
            a_1 "Infections"
            a_2 "Wheezing"
            a_3 "Diarrhea"
            a_neg_1 "Refused"
            a_neg_2 "Don't know"
          QUESTIONS
        }

        let!(:mother_num) {
          create_response_for(questions_map['CHILD_NUM'], m_one_response_set) do |r|
            r.answer = r.question.answers.first
            r.integer_value = 2
          end
        }

        let!(:c1_qnum) {
          create_response_for(questions_map['TV_FREQ_HRS'], c1_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('2 hours')
          end
        }

        let!(:c1_cond_1) {
          create_response_for(questions_map['COND'], c1_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Infections')
            r.response_group = 1
          end
        }

        let!(:c1_cond_2) {
          create_response_for(questions_map['COND'], c1_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Wheezing')
            r.response_group = 2
          end
        }

        let!(:c2_qnum) {
          create_response_for(questions_map['TV_FREQ_HRS'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Refused')
          end
        }

        let!(:c2_cond_1) {
          create_response_for(questions_map['COND'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Refused')
          end
        }

        let!(:c2_cond_2) {
          create_response_for(questions_map['COND'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text("Don't know")
          end
        }

        let(:mother_record) { records.detect { |rec| rec.class.mdes_table_name == 'eighteen_mth_mother' }}

        let(:child_habits_records) {
          records.select { |rec| rec.class.mdes_table_name == 'eighteen_mth_mother_habits'}
        }

        let(:child_cond_records) {
          records.select { |rec| rec.class.mdes_table_name == 'eighteen_mth_mother_cond'}
        }

        let(:child_habits_records_by_p) {
          child_habits_records.inject({}) { |map, rec| map[rec.p_id] = rec; map }
        }

        it 'creates the expected tertiary records' do
          child_cond_records.collect(&:cond).sort.should == %w(-1 -2 1 2) # lex sort
        end

        it 'gives the tertiary records unique IDs' do
          child_cond_records.collect { |rec| rec.key.first }.uniq.size.should == 4
        end

        it 'associates the tertiary records with the correct secondary records' do
          child_cond_records.inject({}) { |h, cond_rec|
            ((h[cond_rec.eighteen_mth_habits_id] ||= []) << cond_rec.cond).sort!; h
          }.should == {
            child_habits_records_by_p[child_participant_1.p_id].key.first => %w(1 2),
            child_habits_records_by_p[child_participant_2.p_id].key.first => %w(-1 -2),
          }
        end
      end

      describe 'with a repeater' do
        let(:mother_survey_part_one) {
          load_survey_questions_string(<<-QUESTIONS)
            q_CHILD_NUM "How many children of this mother are eligible for the 18 month visit today?",
            :help_text => "Enter number value",
            :data_export_identifier=>"EIGHTEEN_MTH_MOTHER.CHILD_NUM"
            a :integer
          QUESTIONS
        }

        # N.b.: while this repeater is in a child survey, it is actually
        # directly associated to the primary (i.e., mother) record. None of
        # the existing repeaters are actually tertiary tables.
        let(:child_survey_habits) {
          load_survey_questions_string(<<-QUESTIONS)
            repeater "Information on non-prescription medicines:" do
              q_OTCMED "What is the name of the drug?",
              :pick => :one,
              :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_OTC.OTCMED"
              a :string
              a_neg_1 "Refused"
              a_neg_2 "Don't know"

              q_OTC_ADMIN "How is the {OTCMED} taken?",
              :pick => :one,
              :data_export_identifier=>"EIGHTEEN_MTH_MOTHER_OTC.OTC_ADMIN"
              a_1 "By mouth,"
              a_2 "Inhaled either by mouth or nose,"
              a_3 "Injected,"
              a_4 "Applied to the skin, such as a patch or creams, or"
              a_5 "Some other way?"
              a_neg_1 "Refused"
              a_neg_2 "Don't know"
            end
          QUESTIONS
        }

        before do
          create_response_for(questions_map['CHILD_NUM'], m_one_response_set) do |r|
            r.integer_value = 2
          end

          # Child 1
          # deliberately created out of order
          create_response_for(questions_map['OTCMED'], c1_habits_response_set) do |r|
            r.string_value = 'Tylenol'
            r.response_group = 2
          end
          create_response_for(questions_map['OTCMED'], c1_habits_response_set) do |r|
            r.string_value = 'Insulin'
            r.response_group = 1
          end
          create_response_for(questions_map['OTC_ADMIN'], c1_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Injected,')
            r.response_group = 1
          end
          create_response_for(questions_map['OTC_ADMIN'], c1_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('By mouth,')
            r.response_group = 2
          end

          # Child 2
          create_response_for(questions_map['OTCMED'], c2_habits_response_set) do |r|
            r.string_value = 'Advil'
            r.response_group = 1
          end
          create_response_for(questions_map['OTCMED'], c2_habits_response_set) do |r|
            r.string_value = 'Soap'
            r.response_group = 2
          end
          create_response_for(questions_map['OTC_ADMIN'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('Inhaled either by mouth or nose,')
            r.response_group = 2
          end
          create_response_for(questions_map['OTC_ADMIN'], c2_habits_response_set) do |r|
            r.answer = r.question.answers.find_by_text('By mouth,')
            r.response_group = 1
          end
        end

        let(:mother_record) { records.detect { |rec| rec.class.mdes_table_name == 'eighteen_mth_mother' }}

        let(:child_otc_records) {
          records.select { |rec| rec.class.mdes_table_name == 'eighteen_mth_mother_otc'}
        }

        let(:child_otc_records_by_p) {
          child_habits_records.inject({}) { |map, rec| map[rec.p_id] = rec; map }
        }

        it 'gives the records unique IDs' do
          child_otc_records.collect { |rec| rec.key.first }.uniq.size.should == 4
        end

        it 'collates grouped response values' do
          child_otc_records.collect { |otc| [otc.otcmed, otc.otc_admin] }.sort.should == [
            ["Advil",   "1"],
            ["Insulin", "3"],
            ["Soap",    "2"],
            ["Tylenol", "1"]
          ]
        end

        it 'associates the records with the correct root record' do
          child_otc_records.collect(&:eighteen_mth_mother_id).uniq.should == [mother_record.key.first]
        end
      end
    end
  end
end
