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

  ##
  # Caches JSON representations of the most recent surveys, as determined by
  # {.most_recent_for_each_title}.
  #
  # If surveys are already cached, then this method only extends the cache
  # lifetime for those surveys; it does not re-generate any JSON.
  #
  # This method caches surveys in batches because that gives us more immediate
  # visibility into the cache results.  The batch size of 20 is just a guess,
  # and is open for benchmarking.
  def self.cache_recent
    cache = SurveyCache.new

    most_recent.find_in_batches(:batch_size => 20) do |chunk|
      to_cache = cache.peek(chunk).select { |_, present| !present }.map(&:first)
      cache.put(to_cache)
      cache.renew(chunk)
    end
  end
end
