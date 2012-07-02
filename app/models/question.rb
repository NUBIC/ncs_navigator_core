# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: questions
#
#  api_id                 :string(255)
#  common_identifier      :string(255)
#  common_namespace       :string(255)
#  correct_answer_id      :integer
#  created_at             :datetime
#  custom_class           :string(255)
#  custom_renderer        :string(255)
#  data_export_identifier :string(255)
#  display_order          :integer
#  display_type           :string(255)
#  display_width          :integer
#  help_text              :text
#  id                     :integer          not null, primary key
#  is_mandatory           :boolean
#  pick                   :string(255)
#  question_group_id      :integer
#  reference_identifier   :string(255)
#  short_text             :text
#  survey_section_id      :integer
#  text                   :text
#  updated_at             :datetime
#



class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods

  default_scope :order => "display_order ASC, id ASC"

end

