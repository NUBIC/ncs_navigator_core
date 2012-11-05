# == Schema Information
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

require 'spec_helper'

require File.expand_path('../../shared/models/a_publicly_identified_record', __FILE__)

describe Question do
  it_should_behave_like 'a publicly identified record' do
    let(:o1) { Factory(:question) }
    let(:o2) { Factory(:question) }
  end
end
