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

class LegacyInstrumentDataValue < ActiveRecord::Base
  belongs_to :legacy_instrument_data_record, :inverse_of => :values

  alias :record :legacy_instrument_data_record

  ##
  # @return [Question,false] A surveyor question whose data export identifier
  #   indicates it matches the variable for this value.
  def question
    if @question.nil?
      result = Question.where(
        "data_export_identifier ILIKE '#{record.mdes_table_name}%.#{mdes_variable_name}'").first
      # memoize to false when no matches
      @question = result || false
    else
      @question
    end
  end

  ##
  # @return [String,nil] The text for {#question} or `nil` if there is none.
  def question_text
    question.text if question
  end

  ##
  # @return [Answer,false] The answer to {#question} whose reference identifier
  #   matches this value.
  def answer
    if @answer.nil?
      result =
        if question && !value.blank?
          question.answers.where('reference_identifier = ?', answer_reference_identifier).first
        end
      # memoize to false when no matches
      @answer = result || false
    else
      @answer
    end
  end

  ##
  # @return [String,nil] The text for {#answer} or `nil` if there is none.
  def answer_text
    answer.text if answer
  end

  def answer_reference_identifier
    case value
    when /^-\d+$/
      value.sub(/^-/, 'neg_')
    else
      value
    end
  end
  private :answer_reference_identifier
end
