# == Schema Information
# Schema version: 20111212224350
#
# Table name: questions
#
#  id                     :integer         not null, primary key
#  survey_section_id      :integer
#  question_group_id      :integer
#  text                   :text
#  short_text             :text
#  help_text              :text
#  pick                   :string(255)
#  reference_identifier   :string(255)
#  data_export_identifier :string(255)
#  common_namespace       :string(255)
#  common_identifier      :string(255)
#  display_order          :integer
#  display_type           :string(255)
#  is_mandatory           :boolean
#  display_width          :integer
#  custom_class           :string(255)
#  custom_renderer        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  correct_answer_id      :integer
#  api_id                 :string(255)
#

class Question < ActiveRecord::Base
  include Surveyor::Models::QuestionMethods

  default_scope :order => "display_order ASC, id ASC"

end
