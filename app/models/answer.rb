# == Schema Information
#
# Table name: answers
#
#  api_id                 :string(255)
#  common_identifier      :string(255)
#  common_namespace       :string(255)
#  created_at             :datetime
#  custom_class           :string(255)
#  custom_renderer        :string(255)
#  data_export_identifier :string(255)
#  default_value          :string(255)
#  display_length         :integer
#  display_order          :integer
#  display_type           :string(255)
#  help_text              :text
#  id                     :integer          not null, primary key
#  is_exclusive           :boolean
#  question_id            :integer
#  reference_identifier   :string(255)
#  response_class         :string(255)
#  short_text             :text
#  text                   :text
#  updated_at             :datetime
#  weight                 :integer
#

class Answer < ActiveRecord::Base
  include NcsNavigator::Core::Surveyor::HasPublicId
  include Surveyor::Models::AnswerMethods
end
