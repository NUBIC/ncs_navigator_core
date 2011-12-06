# == Schema Information
# Schema version: 20111205175632
#
# Table name: responses
#
#  id                :integer         not null, primary key
#  response_set_id   :integer
#  question_id       :integer
#  answer_id         :integer
#  datetime_value    :datetime
#  integer_value     :integer
#  float_value       :float
#  unit              :string(255)
#  text_value        :text
#  string_value      :string(255)
#  response_other    :string(255)
#  response_group    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  survey_section_id :integer
#

class Response < ActiveRecord::Base
  include Surveyor::Models::ResponseMethods

  def source_mdes_record=(record)
    self.source_mdes_table = record.class.mdes_table_name
    self.source_mdes_id = record.key.first
  end

  def reportable_value
    case answer.response_class
    when 'answer'
      self.answer.reference_identifier.sub(/neg_/, '-')
    when 'string'
      self.string_value
    when 'integer'
      self.integer_value
    when 'datetime'
      self.datetime_value.iso8601[0,19]
    else
      fail "Unsupported response class in #reportable_value: #{answer.response_class}"
    end
  end
end
