require 'spec_helper'

require File.expand_path('../importer_warehouse_setup', __FILE__)

module NcsNavigator::Core::Warehouse
  describe InstrumentImporter, :clean_with_truncation, :slow do
    MdesModule = NcsNavigator::Warehouse::Models::TwoPointZero

    include_context :importer_spec_warehouse

    let!(:twq_survey) {
      load_survey_string(<<-DSL)
        survey "INS_ENV_TapWaterPestTechCollect_DCI_EHPBHI_P2_V1.0" do
          section "A" do
            q_TIME_STAMP_1 "Insert date/time stamp", :data_export_identifier=>"TAP_WATER_TWQ.TIME_STAMP_1"
            a :datetime, :custom_class => "datetime"

            q_TWQ_SUBSAMPLES "What TWQ samples should be collected at this visit?",
            :pick => :any,
            :data_export_identifier=>"TAP_WATER_TWQ_SUBSAMPLES.TWQ_SUBSAMPLES"
            a_1 "Participant TWQ"
            a_2 "Technician TWQ"
            a_3 "Technician TWQ blank"
            a_4 "Technician TWQ duplicate"

            q_TWQ_LOCATION "Can you show us a faucet where we can collect the sample? We would prefer to sample from a kitchen faucet",
            :pick => :one,
            :data_export_identifier=>"TAP_WATER_TWQ.TWQ_LOCATION"
            a_1 "Kitchen"
            a_2 "Bathroom sink/tub"
            a_neg_5 "Other"

            q_TWQ_LOCATION_OTH "Specify other location",
            :data_export_identifier=>"TAP_WATER_TWQ.TWQ_LOCATION_OTH"
            a "Specify", :string
          end
        end
      DSL
    }

    let!(:pv2_survey) {
      load_survey_string(<<-DSL)
        survey "INS_QUE_PregVisit2_INT_EHPBHI_P2_V2.0" do
          section "CAPI", :reference_identifier=>"prepregnancy_visit_2_v20" do
            q_r_fname "First name", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.R_FNAME"
            a :string
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

            q_r_lname "Last name", :pick=>:one, :data_export_identifier=>"PREG_VISIT_2_2.R_LNAME"
            a :string
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

            q_HOSP_NIGHTS "How many nights did you stay in the hospital during this hospital stay?",
            :pick=>:one,
            :data_export_identifier=>"PREG_VISIT_2_2.HOSP_NIGHTS"
            a "Number", :integer
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

            q_BIRTH_PLAN_OLD "So we make sure we have the correct information, where do you plan to deliver your {baby/babies}?",
            :pick => :one,
            :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLAN"
            a_1 "In a hospital"
            a_2 "A birthing center"
            a_3 "At home, or"
            a_4 "Some other place?"
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

            q_birth_plan "Where do you plan to deliver your {baby/babies}?",
            :pick => :one,
            :data_export_identifier=>"PREG_VISIT_2_2.BIRTH_PLAN"
            a_1 "In a hospital"
            a_2 "A birthing center"
            a_3 "At home, or"
            a_4 "Some other place?"
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

          end
        end
      DSL
    }

    let!(:pre_preg_survey) {
      load_survey_string(<<-DSL)
        survey "INS_QUE_PrePreg_INT_EHPBHI_P2_V1.1" do
          section 'CAPI' do
            q_decorate "In the past 12 months, were any smaller projects done in your home, such as painting, wallpapering,
            refinishing floors, or installing new carpet?", :pick=>:one,
            :data_export_identifier=>"PRE_PREG.DECORATE"
            a_1 "Yes"
            a_2 "No"
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

            q_decorate_room "In which rooms were these smaller projects done?",
            :help_text => "Probe for any other responses: Any others? Select all that apply",
            :pick=>:any,
            :data_export_identifier=>"PRE_PREG_PDECORATE_ROOM.DECORATE_ROOM"
            a_1 "Kitchen"
            a_2 "Living room"
            a_3 "Hall/landing"
            a_4 "Participant's bedroom"
            a_5 "Other bedroom"
            a_6 "Bathroom/toilet"
            a_7 "Basement"
            a_neg_5 "Other"
            a_neg_1 "Refused"
            a_neg_2 "Don't know"

            q_enter_decorate_room_oth "Other rooms where smaller projects were done",
            :pick=>:one, :data_export_identifier=>"PRE_PREG_PDECORATE_ROOM.DECORATE_ROOM_OTH"
            a_1 "Specify", :string
            a_neg_1 "Refused"
            a_neg_2 "Don't know"
          end
        end
      DSL
    }

    let(:importer) { InstrumentImporter.new(wh_config) }

    let(:core_event) { Factory(:event) }
    let(:core_instrument) { Factory(:instrument) }

    let(:wh_participant) { create_mdes_record(MdesModule::Participant, 'FR3D') }
    let(:wh_event) {
      create_mdes_record(MdesModule::Event, core_event.public_id, :event_start_date => '2010-10-01')
    }
    let(:wh_instrument) {
      create_mdes_record(MdesModule::Instrument, core_instrument.public_id)
    }

    let(:possible_non_question_fields) {
      {
        :p => lambda { wh_participant },
        :event => lambda { wh_event },
        :event_type => lambda { core_event.event_type_code },
        :event_repeat_key => lambda { core_event.event_repeat_key },
        :instrument => lambda { wh_instrument },
        :instrument_version => lambda { core_instrument.instrument_version },
        :instrument_repeat_key => lambda { core_instrument.instrument_repeat_key },
        :psu_id => lambda { '20000032' },
        :recruit_type => lambda { '3' }
      }
    }

    before do
      Survey.mdes_reset!
      ResponseSet.count.should == 0
    end

    def create_mdes_record(model, id, attributes={}, validate=true)
      model.new(all_missing_attributes(model).merge(attributes)).tap do |record|
        record.send("#{record.class.key.first.name}=", id)

        possible_non_question_fields.each do |k, v|
          setter = "#{k}="
          if record.respond_to?(setter)
            record.send(setter, v.call)
          end
        end

        if validate
          unless record.save
            fail "Could not save #{record} due to validation failures: #{record.errors.to_a.join(', ')}"
          end
        else
          record.save!
        end
      end
    end

    # TODO: the passive naming here is weird
    describe 'a ResponseSet' do
      let!(:twq_rec) {
        create_mdes_record(MdesModule::TapWaterTwq, 'PV11', :twq_location => 1)
      }

      it 'is created for each primary instrument record with a survey' do
        create_mdes_record(MdesModule::TapWaterTwq, 'PV12', :twq_location => 1)
        create_mdes_record(MdesModule::PregVisit22, 'PV21')

        importer.import

        ResponseSet.count.should == 3
      end

      it 'is not created for instrument records without corresponding surveys' do
        create_mdes_record(MdesModule::PregVisit1, 'PV10')

        importer.import

        ResponseSet.count.should == 1 # just :twq_rec
      end

      it 'uses the table name plus the primary table ID as its access code' do
        importer.import

        ResponseSet.first.access_code.should == 'tap_water_twq#PV11'
      end

      describe 'with many records' do
        before do
          pending 'This test is absurdly slow'
          start = Time.now
          1.upto(2793) do |i|
            create_mdes_record(
              MdesModule::TapWaterTwq, i.to_s,
              {:twq_location => '-5', :twq_location_oth => "Location #{i}"},
              false)
            print "\r[before] %.3f created per sec / #{i} total" % [i.to_f / (Time.now - start)]
          end
          puts ' ... done'
        end

        it 'is created for every one' do
          importer.import

          ResponseSet.count.should == 2794 # don't forget twq_rec
        end
      end

      it 'is associated with the Core instrument record' do
        importer.import

        ResponseSet.first.instrument.should == core_instrument
      end

      it 'is associated with the source survey' do
        importer.import

        ResponseSet.first.survey.should == twq_survey
      end

      it 'is reused for an updated instrument' do
        importer.import
        ResponseSet.all.collect(&:access_code).should == %w(tap_water_twq#PV11)

        twq_rec.time_stamp_1 = '2010-10-01T10:01:10'
        twq_rec.save

        importer.import
        ResponseSet.all.collect(&:access_code).should == %w(tap_water_twq#PV11)
      end

      it 'is audited on creation' do
        with_versioning { importer.import }

        audit_record = Version.where(:item_type => ResponseSet.to_s).first
        audit_record.should_not be_nil
      end

      it 'is audited as being from the importer' do
        with_versioning { importer.import }

        audit_record = Version.where(:item_type => ResponseSet.to_s).first
        audit_record.whodunnit.should == 'instrument_importer'
      end
    end

    describe 'a Response' do
      describe 'for the primary model' do
        let!(:twq_rec) {
          create_mdes_record(MdesModule::TapWaterTwq, 'TWQ1',
            :twq_location => '-5', :twq_location_oth => 'ceramic fountain')
        }

        before do
          importer.import
        end

        it 'exists for each non-null field that maps to a question' do
          Response.count.should == 2
        end

        it 'preserves identification of the source record' do
          Response.first.source_mdes_table.should == 'tap_water_twq'
          Response.first.source_mdes_id.should == 'TWQ1'
        end

        it 'is not duplicated when incrementally importing' do
          importer.import

          Response.count.should == 2
        end
      end

      describe 'typed responses' do
        it 'is a string value when the question demands it' do
          create_mdes_record(MdesModule::TapWaterTwq, 'TWQ1',
            :twq_location => '-5',
            :twq_location_oth => 'ceramic fountain')
          importer.import

          q = Question.find_by_reference_identifier('TWQ_LOCATION_OTH')
          actual = Response.where(:question_id => q.id).first

          actual.string_value.should == 'ceramic fountain'
          actual.answer.should == q.answers.find_by_response_class('string')
        end

        it 'is an integer value when the question demands it' do
          create_mdes_record(MdesModule::PregVisit22, 'PV22', :hosp_nights => '3')
          importer.import

          Response.first.integer_value.should == 3
          Response.first.answer.should ==
            Question.find_by_reference_identifier('HOSP_NIGHTS').
              answers.find_by_response_class('integer')
        end

        it 'is a datetime value when the question demands it' do
          create_mdes_record(MdesModule::TapWaterTwq, 'TWQ1',
            :twq_location => '1',
            :time_stamp_1 => '2012-11-12T05:06:07')
          importer.import

          q = Question.find_by_reference_identifier('TIME_STAMP_1')
          actual = Response.where(:question_id => q.id).first

          actual.datetime_value.should == Time.local(2012, 11, 12, 5, 6, 7)
          actual.answer.should == q.answers.find_by_response_class('datetime')
        end

        it 'ignores unparseable datetime values' do
          create_mdes_record(MdesModule::TapWaterTwq, 'TWQ1',
            :twq_location => '1',
            :time_stamp_1 => '9333-93-93T93:93:93')
          importer.import

          q = Question.find_by_reference_identifier('TIME_STAMP_1')
          Response.where(:question_id => q.id).should == []
        end

        it 'ignores -4 values if not present as an option' do
          create_mdes_record(MdesModule::PregVisit22, 'PV22', :hosp_nights => '-4')
          importer.import

          Response.count.should == 0
        end

        it 'ignores -3 values if not present as an option' do
          create_mdes_record(MdesModule::PregVisit22, 'PV22', :hosp_nights => '-3')
          importer.import

          Response.count.should == 0
        end
      end

      describe 'for a coded-or-literal variable' do
        it 'is an "answer" response when coded' do
          create_mdes_record(MdesModule::PregVisit22, 'PV22', :hosp_nights => '-2')
          importer.import

          Response.first.answer.should ==
            Question.find_by_reference_identifier('HOSP_NIGHTS').
              answers.find_by_reference_identifier('neg_2')
        end

        it 'is a the literal value when literal' do
          create_mdes_record(MdesModule::PregVisit22, 'PV22', :hosp_nights => '3')
          importer.import

          Response.first.integer_value.should == 3
          Response.first.answer.should ==
            Question.find_by_reference_identifier('HOSP_NIGHTS').
              answers.find_by_response_class('integer')
        end
      end

      describe 'when multiple questions map to a variable' do
        let(:q1) { Question.find_by_reference_identifier('BIRTH_PLAN_OLD') }
        let(:q2) { Question.find_by_reference_identifier('birth_plan') }

        before do
          create_mdes_record(MdesModule::PregVisit22, 'PV22', :birth_plan => '3')
          importer.import
        end

        it 'creates a response for each question' do
          Response.count.should == 2
        end

        it 'has the appropriate value for the first response' do
          actual = Response.where(:question_id => q1).first.answer
          actual.question.should == q1
          actual.reference_identifier.should == '3'
        end

        it 'has the appropriate value for the second response' do
          actual = Response.where(:question_id => q2).first.answer
          actual.reference_identifier.should == '3'
          actual.question.should == q2
        end
      end

      describe 'for a multivalued association' do
        let(:question) { Question.find_by_reference_identifier('TWQ_SUBSAMPLES') }
        let(:responses) { Response.where(:question_id => question.id) }

        before do
          primary = create_mdes_record(MdesModule::TapWaterTwq, 'TWQ1', :twq_location => '1')
          create_mdes_record(MdesModule::TapWaterTwqSubsamples, 'AK', :twq_subsamples => '3',
            :tap_water_twq => primary)
          create_mdes_record(MdesModule::TapWaterTwqSubsamples, 'EH', :twq_subsamples => '4',
            :tap_water_twq => primary)
          importer.import
        end

        it 'has one Response per record' do
          responses.collect { |r| r.answer.reference_identifier }.sort.should == %w(3 4)
        end

        it 'preserves identification of the source record' do
          responses.collect { |r| [r.source_mdes_table, r.source_mdes_id] }.should == [
            %w(tap_water_twq_subsamples AK),
            %w(tap_water_twq_subsamples EH)
          ]
        end

        it 'has one ResponseSet per primary record' do
          ResponseSet.count.should == 1
        end
      end

      describe 'for a multivalued association with an other' do
        let(:multi_question) { Question.find_by_reference_identifier('decorate_room') }
        let(:other_question) { Question.find_by_reference_identifier('enter_decorate_room_oth') }

        let(:response_set) { importer.import; ResponseSet.first }
        let(:multi_responses) { response_set.responses.where(:question_id => multi_question.id) }
        let(:other_responses) { response_set.responses.where(:question_id => other_question.id) }

        before do
          primary = create_mdes_record(MdesModule::PrePreg, 'PP1', :decorate => '1')
          create_mdes_record(MdesModule::PrePregPdecorateRoom, 'PP1-2', :decorate_room => '2',
            :pp => primary)
          create_mdes_record(MdesModule::PrePregPdecorateRoom, 'PP1-oth', :decorate_room => '-5',
            :decorate_room_oth => 'Garage', :pp => primary)
          create_mdes_record(MdesModule::PrePregPdecorateRoom, 'PP1-4', :decorate_room => '4',
            :pp => primary)
        end

        it 'has one Response to the coded question for each record' do
          multi_responses.collect { |r| r.answer.reference_identifier }.sort.should == %w(2 4 neg_5)
        end

        it 'has only one Response to the other question' do
          other_responses.collect(&:string_value).should == %w(Garage)
        end

        describe 'when the other value is filled in on the wrong records' do
          before do
            MdesModule::PrePregPdecorateRoom.
              find('PP1-2').tap { |rec| rec.decorate_room_oth = 'Helipad' }.save
          end

          it 'still has one Response to the coded question for each record' do
            multi_responses.
              collect { |r| r.answer.reference_identifier }.sort.should == %w(2 4 neg_5)
          end

          it 'still has only one Response to the other question' do
            other_responses.collect(&:string_value).should == %w(Garage)
          end
        end
      end
    end
  end
end
