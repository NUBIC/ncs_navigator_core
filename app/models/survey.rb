# == Schema Information
# Schema version: 20120120165946
#
# Table name: surveys
#
#  id                     :integer         not null, primary key
#  title                  :string(255)
#  description            :text
#  access_code            :string(255)
#  reference_identifier   :string(255)
#  data_export_identifier :string(255)
#  common_namespace       :string(255)
#  common_identifier      :string(255)
#  active_at              :datetime
#  inactive_at            :datetime
#  css_url                :string(255)
#  custom_class           :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  display_order          :integer
#  api_id                 :string(255)
#

class Survey < ActiveRecord::Base
  include Surveyor::Models::SurveyMethods
  include NcsNavigator::Core::MdesInstrumentSurvey

  def self.where_title_like(title)
    Survey.where_access_code_like(Survey.to_normalized_string(title))
  end

  def self.most_recent_for_title(title)
    Survey.most_recent_for_access_code(Survey.to_normalized_string(title))
  end

  def self.where_access_code_like(code)
    Survey.where("access_code like ?", "%#{code}%").order("created_at DESC")
  end

  def self.most_recent_for_access_code(code)
    Survey.where_access_code_like(code).first
  end

  def self.most_recent_for_each_title
    title_index = {}
    Survey.order('created_at DESC').all.each do |survey|
      actual_title =
        if survey.title =~ /^(\S+)\s+\d+$/
          $1
        else
          survey.title
        end
      title_index[actual_title] ||= survey
    end
    title_index.values.sort_by { |s| s.title }
  end
end
