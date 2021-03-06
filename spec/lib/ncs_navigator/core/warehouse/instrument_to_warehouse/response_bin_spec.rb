# -*- coding: utf-8 -*-

require 'spec_helper'
require 'ncs_navigator/core/warehouse/instrument_to_warehouse'

module NcsNavigator::Core::Warehouse::InstrumentToWarehouse
  # N.b.: ResponseBin is an internal implementation detail of
  # InstrumentToWarehouse. It is not intended to be used outside of that
  # module's mixin methods. These specs are necessary, however, because it's not
  # possible to simulate some aspects of the desired behavior reliably when
  # operating on full instruments/response sets.
  describe ResponseBin, :warehouse do
    let(:survey_with_other) {
      load_survey_questions_string(<<-DSL)
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

    let(:participant1) { Factory(:participant, :p_id => 'P1') }
    let(:participant2) { Factory(:participant, :p_id => 'P2') }

    let(:response_set_for_p1) { Factory(:response_set, :participant => participant1, :survey => survey_with_other) }
    let(:response_set_for_p2) { Factory(:response_set, :participant => participant2, :survey => survey_with_other) }

    before do
      Survey.mdes_reset!
    end

    def create_response_for(question, response_set, response_attributes={})
      q = case question
          when String
            questions = response_set.survey.sections.collect(&:questions).flatten
            questions.detect { |q| q.reference_identifier == question }
          else
            question
          end

      response_set.responses.build({:question => q}.merge(response_attributes)).tap { |r|
        if block_given?
          yield r

          unless r.answer
            if r.string_value
              r.answer = r.question.answers.find_by_response_class('string')
            elsif r.integer_value
              r.answer = r.question.answers.find_by_response_class('integer')
            end
          end
        else
          r.answer = r.question.answers.first
        end

        fail 'Answer is nil' unless r.answer
        r.save!
      }
    end

    describe '#will_accept?' do
      let(:bin) {
        ResponseBin.new(
          participant1,
          'twelve_mth_mother_renovate_room',
          {}, # DC
          nil
        )
      }

      it 'will not accept a response for a different participant' do
        bin.will_accept?(create_response_for('RENOVATE_ROOM', response_set_for_p2)).
          should be_false
      end

      it 'will not accept a response from a different response group' do
        bin.will_accept?(create_response_for('RENOVATE_ROOM', response_set_for_p1, :response_group => '2')).
          should be_false
      end

      it 'will not accept a second response for the same question' do
        bin << create_response_for('RENOVATE_ROOM', response_set_for_p1)

        bin.will_accept?(create_response_for('RENOVATE_ROOM', response_set_for_p1)).
          should be_false
      end

      it 'will not accept a response for a different MDES table' do
        bin.will_accept?(create_response_for('RENOVATE', response_set_for_p1)).
          should be_false
      end

      it 'will accept a response which meets all the other criteria' do
        bin << create_response_for('RENOVATE_ROOM_OTH', response_set_for_p1)

        acceptable_response = create_response_for('RENOVATE_ROOM', response_set_for_p1) { |r|
          r.answer = r.question.answers.find_by_reference_identifier('neg_5') 
        }

        bin.will_accept?(acceptable_response).
          should be_true
      end

      describe 'considering "other" pairs' do
        let!(:other_value_response) {
          create_response_for('RENOVATE_ROOM_OTH', response_set_for_p1) { |r|
            r.string_value = 'Observatory'
          }
        }

        let!(:coded_as_other_response) {
          create_response_for('RENOVATE_ROOM', response_set_for_p1) { |r|
            r.answer = r.question.answers.find_by_reference_identifier('neg_5')
          }
        }

        let!(:coded_as_not_other_response) {
          create_response_for('RENOVATE_ROOM', response_set_for_p1) { |r|
            r.answer = r.question.answers.find_by_reference_identifier('6')
          }
        }

        describe 'with response for the coded question' do
          describe 'when the bin contains the "other" value response' do
            before do
              bin << other_value_response
            end

            it 'will accept the coded "other" response' do
              bin.will_accept?(coded_as_other_response).should be_true
            end

            it 'will not accept a coded non-other response' do
              bin.will_accept?(coded_as_not_other_response).should be_false
            end
          end

          describe 'when the bin does not contain the "other" value response' do
            it 'will accept a coded other response' do
              bin.will_accept?(other_value_response).should be_true
            end

            it 'will accept the coded "other" response' do
              bin.will_accept?(coded_as_other_response).should be_true
            end

            it 'will accept a coded non-other response' do
              bin.will_accept?(coded_as_not_other_response).should be_true
            end
          end
        end

        describe 'with a response for the value question' do
          it 'will accept the other value response when it contains the other coded response' do
            bin << coded_as_other_response

            bin.will_accept?(other_value_response).should be_true
          end

          it 'will not accept the other value when it contains the a non-other coded response' do
            bin << coded_as_not_other_response

            bin.will_accept?(other_value_response).should be_false
          end

          it 'will accept an other value when it does not contain a corresponding coded response at all' do
            bin.will_accept?(other_value_response).should be_true
          end
        end
      end
    end

    describe '#must_have?' do
      let(:bin) {
        ResponseBin.new(
          participant1,
          'twelve_mth_mother_renovate_room',
          {}, # DC
          nil
        )
      }

      it 'is false for some random response' do
        bin.must_have?(create_response_for('RENOVATE_ROOM', response_set_for_p1)).
          should be_false
      end

      describe 'considering "other" pairs' do
        let!(:other_value_response) {
          create_response_for('RENOVATE_ROOM_OTH', response_set_for_p1) { |r|
            r.string_value = 'Observatory'
          }
        }

        let!(:coded_as_other_response) {
          create_response_for('RENOVATE_ROOM', response_set_for_p1) { |r|
            r.answer = r.question.answers.find_by_reference_identifier('neg_5')
          }
        }

        let!(:coded_as_not_other_response) {
          create_response_for('RENOVATE_ROOM', response_set_for_p1) { |r|
            r.answer = r.question.answers.find_by_reference_identifier('6')
          }
        }

        describe 'when it contains a coded other response' do
          before do
            bin << coded_as_other_response
          end

          it 'must have the other value response' do
            bin.must_have?(other_value_response).should be_true
          end

          it 'must not have the other value response' do
            bin.must_have?(coded_as_not_other_response).should be_false
          end
        end

        describe 'when it contains a coded non-other response' do
          before do
            bin << coded_as_not_other_response
          end

          it 'must not have the other value response' do
            bin.must_have?(other_value_response).should be_false
          end

          it 'must not have the other coded value response' do
            bin.must_have?(coded_as_other_response).should be_false
          end
        end

        describe 'when it contains an other value' do
          before do
            bin << other_value_response
          end

          it 'must have the other coded response' do
            bin.must_have?(coded_as_other_response).should be_true
          end

          it 'must not have the a non-other coded response' do
            bin.must_have?(coded_as_not_other_response).should be_false
          end
        end
      end
    end
  end
end
