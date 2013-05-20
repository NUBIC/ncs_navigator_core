# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: responses
#
#  answer_id         :integer
#  api_id            :string(255)
#  created_at        :datetime
#  datetime_value    :datetime
#  float_value       :float
#  id                :integer          not null, primary key
#  integer_value     :integer
#  lock_version      :integer          default(0)
#  question_id       :integer
#  response_group    :string(255)
#  response_other    :string(255)
#  response_set_id   :integer          not null
#  source_mdes_id    :string(36)
#  source_mdes_table :string(100)
#  string_value      :string(255)
#  survey_section_id :integer
#  text_value        :text
#  unit              :string(255)
#  updated_at        :datetime
#

class Response < ActiveRecord::Base
  include NcsNavigator::Core::Surveyor::HasPublicId
  include NcsNavigator::Core::Surveyor::ResponseValue
  include Surveyor::Models::ResponseMethods

  default_scope includes(:answer, :question)

  validate :ensure_association_integrity

  ##
  # Raise an error if the answer associated with this Response
  # is not in the set of answers for the associated Question.
  def ensure_association_integrity
    if answer_id && question
      valid_answer_ids = Answer.where(:question_id => self.question_id).map(&:id)
      unless valid_answer_ids.include?(answer_id)
        raise "Error: answer_id #{answer_id} not in the set of answers [#{valid_answer_ids}] for question #{question.id}"
      end
    end
  end

  with_options(:as => :system) do |r|
    r.attr_accessible :answer, :question, :value
  end

  def self.for_merge
    includes(:answer, :question, :response_set)
  end

  def source_mdes_record=(record)
    self.source_mdes_table = record.class.mdes_table_name
    self.source_mdes_id = record.key.first
  end

  def reportable_value
    case answer.response_class
    when 'answer'
      self.answer.reference_identifier.sub(/neg_/, '-')
    when 'string'
      reportable_string_value
    when 'integer'
      self.integer_value ? self.integer_value.to_s : nil
    when 'datetime'
      self.datetime_value.try(:iso8601).try(:[], 0, 19)
    when 'date'
      self.date_value
    when 'time'
      self.time_value
    when 'float'
      self.float_value ? self.float_value.to_s : nil
    when 'text'
      self.text_value
    else
      fail "Unsupported response class in #reportable_value: #{answer.response_class}"
    end
  end

  ##
  # In cases where the response string value needs to be formatted
  # to the MDES specifications, format the response.
  # Otherwise (most of the time), simply return the string_value
  # @return [String]
  def reportable_string_value
    if answer.custom_class_present?("phone")
      self.string_value.scan(/\d/).join unless self.string_value.blank?
    else
      self.string_value
    end
  end

  # Ported from NUBIC/surveyor#450. Can be removed when we are using a version
  # of Surveyor which includes that PR.
  def date_value=(val)
    self.datetime_value =
      if val && time = Time.zone.parse(val)
        time.to_datetime
      else
        nil
      end
  end

  # Ported from NUBIC/surveyor#450. Can be removed when we are using a version
  # of Surveyor which includes that PR.
  def time_value=(val)
    self.datetime_value =
      if val && time = Time.zone.parse("#{Date.today.to_s} #{val}")
        time.to_datetime
      else
        nil
      end
  end

end
