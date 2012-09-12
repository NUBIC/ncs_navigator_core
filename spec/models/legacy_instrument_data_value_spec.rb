# == Schema Information
#
# Table name: legacy_instrument_data_values
#
#  created_at                       :datetime
#  id                               :integer          not null, primary key
#  legacy_instrument_data_record_id :integer          not null
#  mdes_variable_name               :string(50)       not null
#  updated_at                       :datetime
#  value                            :text
#

require 'spec_helper'

describe LegacyInstrumentDataValue do
  let(:record) { Factory(:legacy_instrument_data_record, :mdes_table_name => 'frob') }
  let(:value) {
    Factory(:legacy_instrument_data_value, :legacy_instrument_data_record => record)
  }

  it 'belongs to an instrument' do
    value.legacy_instrument_data_record.should be_a(LegacyInstrumentDataRecord)
  end

  describe 'survey component lookup' do
    let!(:a_survey) {
      load_survey_questions_string <<-QUESTIONS
        q_one 'Is this one?', :data_export_identifier => 'FROB.BAR'
        a_1 'Yes'
        a_2 'No'
        a_neg_1 'Refused'

        q_too 'Are there too many questions?', :data_export_identifier => 'FROB[baz=5].QUUX'
        a :string
      QUESTIONS
    }

    let(:q_one) { Question.find_by_reference_identifier('one') }
    let(:q_too) { Question.find_by_reference_identifier('too') }

    before do
      value.update_attribute(:mdes_variable_name, 'bar')
    end

    describe '#question' do
      it 'is false if does not match the table' do
        record.update_attribute(:mdes_table_name, 'echo')
        value.question.should be_false
      end

      it 'is false if it does not match the variable name' do
        value.update_attribute(:mdes_variable_name, 'beep')
        value.question.should be_false
      end

      it 'is the question object if the table and variable match' do
        value.question.should == q_one
      end

      it 'is the question object if the table and variable match, ignoring any fixed values' do
        value.update_attribute(:mdes_variable_name, 'quux')
        value.question.should == q_too
      end
    end

    describe '#question_text' do
      it 'is the text for the question when there is one' do
        value.question_text.should == 'Is this one?'
      end

      it 'is nil otherwise' do
        record.update_attribute(:mdes_table_name, 'something_else')
        value.question_text.should be_nil
      end
    end

    describe '#answer' do
      let(:q_one_yes)     { q_one.answers.where('reference_identifier = ?', '1').first }
      let(:q_one_refused) { q_one.answers.where('reference_identifier = ?', 'neg_1').first }

      it 'is false if there is no question' do
        record.update_attribute(:mdes_table_name, 'e')
        value.answer.should be_false
      end

      it 'is the answer (from the question) whose reference identifier exactly matches the raw value' do
        value.update_attribute(:value, '1')
        value.answer.should == q_one_yes
      end

      it 'is matches a neg_ reference identifier to a negative integer raw value' do
        value.update_attribute(:value, '-1')
        value.answer.should == q_one_refused
      end

      it 'is false if value is blank' do
        value.update_attribute(:value, nil)
        value.answer.should be_false
      end

      it 'is false if none of the answers match the value' do
        value.update_attribute(:value, '18')
        value.answer.should be_false
      end

      it 'does not match an answer from a different question' do
        value.update_attributes(:value => '1', :mdes_variable_name => 'quux')
        value.answer.should be_false
      end
    end

    describe '#answer_text' do
      it 'is the text for the answer when there is one' do
        value.update_attribute(:value, '-1')
        value.answer_text.should == 'Refused'
      end

      it 'is nil otherwise' do
        value.update_attribute(:value, nil)
        value.answer_text.should be_nil
      end
    end
  end
end
