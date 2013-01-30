# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: surveys
#
#  access_code            :string(255)
#  active_at              :datetime
#  api_id                 :string(255)
#  common_identifier      :string(255)
#  common_namespace       :string(255)
#  created_at             :datetime
#  css_url                :string(255)
#  custom_class           :string(255)
#  data_export_identifier :string(255)
#  description            :text
#  display_order          :integer
#  id                     :integer          not null, primary key
#  inactive_at            :datetime
#  instrument_type        :integer
#  instrument_version     :string(36)
#  reference_identifier   :string(255)
#  survey_version         :integer          default(0)
#  title                  :string(255)
#  updated_at             :datetime
#

class Survey < ActiveRecord::Base
  include Surveyor::Models::SurveyMethods
  include NcsNavigator::Core::Surveyor::HasPublicId
  include NcsNavigator::Core::MdesInstrumentSurvey

  attr_accessible :instrument_version, :instrument_type

  def self.most_recent
    maximums = unscoped.select(['title AS t', 'MAX(survey_version) AS ver']).
      group('t')

    joins(%Q{
      INNER JOIN (#{maximums.to_sql})
      AS sv
      ON sv.t = title AND sv.ver = survey_version
    })
  end

  def self.most_recent_for_access_code(code)
    most_recent.where(:access_code => Survey.to_normalized_string(code)).first
  end
end

