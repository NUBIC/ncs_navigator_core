# -*- coding: utf-8 -*-


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
    return [] if code.blank?
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

