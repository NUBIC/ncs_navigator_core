# -*- coding: utf-8 -*-


class ResponseSet < ActiveRecord::Base
  include Surveyor::Models::ResponseSetMethods
  belongs_to :person, :foreign_key => :user_id, :class_name => 'Person', :primary_key => :id
  belongs_to :instrument, :inverse_of => :response_set

  def has_responses_in_each_section_with_questions?
    result = false
    survey.sections_with_questions.each do |section|
      section_questions = section.questions.select { |q| !q.answers.blank? }
      next if section_questions.blank?

      # There is a section with questions who has no answered questions
      if section_questions.select { |q| is_answered?(q) }.count == 0
        result = false
        break
      else
        result = true
      end
    end
    result
  end

  def enumerable_as_instrument?
    return false unless instrument_id

    self.class.connection.select_value(<<-QUERY).to_i > 0
     SELECT COUNT(*)
     FROM instruments i INNER JOIN events e ON i.event_id=e.id
     WHERE i.id=#{instrument_id} AND e.event_disposition IS NOT NULL
    QUERY
  end
end

