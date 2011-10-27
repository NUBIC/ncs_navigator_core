class Survey < ActiveRecord::Base
  include Surveyor::Models::SurveyMethods

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

end
