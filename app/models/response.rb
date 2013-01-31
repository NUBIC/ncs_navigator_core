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
  include Surveyor::Models::ResponseMethods

  ##
  # Used by {#value=} to recognize datetimes, dates, and times.
  ISO8601_HHMM_FORMAT = /\A\s*\d{4}-\d{2}-\d{2}T\d{2}:\d{2}([+-]\d{4}|Z)\s*\Z/
  DATE_FORMAT = /\A\s*\d{4}-\d{2}-\d{2}\s*\Z/
  TIME_FORMAT = /\A\s*\d{2}:\d{2}\s*\Z/

  def self.default_scope; end

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

  def value=(val)
    case val
    when String
      # This is pretty crazy.
      #
      # See
      # https://github.com/NUBIC/surveyor/blob/0a4424ce6b732d111954354ec9c1c7e21d6ebc9b/lib/surveyor/models/response_methods.rb#L92-L103
      # for Surveyor expectations on presenting dates, times, and datetimes as
      # JSON.
      if val =~ ISO8601_HHMM_FORMAT
        self.datetime_value = Time.parse(val)
      elsif val =~ DATE_FORMAT
        self.date_value = val
      elsif val =~ TIME_FORMAT
        self.time_value = val
      end

      self.string_value = val
    when Integer
      self.integer_value = val
    when Float
      self.float_value = val
    end
  end

  def value
    a = answer

    as(a.response_class.to_sym) unless a.response_class == 'answer'
  end
end
