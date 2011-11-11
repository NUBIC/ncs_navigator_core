# == Schema Information
# Schema version: 20111110015749
#
# Table name: response_sets
#
#  id                                        :integer         not null, primary key
#  user_id                                   :integer
#  survey_id                                 :integer
#  access_code                               :string(255)
#  started_at                                :datetime
#  completed_at                              :datetime
#  created_at                                :datetime
#  updated_at                                :datetime
#  contact_link_id                           :integer
#  processed_for_operational_data_extraction :boolean
#

class ResponseSet < ActiveRecord::Base
  include Surveyor::Models::ResponseSetMethods
  belongs_to :person, :foreign_key => :user_id, :class_name => 'Person', :primary_key => :id
  belongs_to :contact_link
end
