# == Schema Information
# Schema version: 20120515181518
#
# Table name: response_sets
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  survey_id     :integer
#  access_code   :string(255)
#  started_at    :datetime
#  completed_at  :datetime
#  created_at    :datetime
#  updated_at    :datetime
#  instrument_id :integer
#  api_id        :string(255)
#

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

end
