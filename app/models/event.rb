# == Schema Information
# Schema version: 20110811161140
#
# Table name: events
#
#  id                              :integer         not null, primary key
#  psu_code                        :integer         not null
#  event_id                        :binary          not null
#  participant_id                  :integer
#  event_type_code                 :integer         not null
#  event_type_other                :string(255)
#  event_repeat_key                :integer
#  event_disposition               :integer
#  event_disposition_category_code :integer         not null
#  event_start_date                :date
#  event_start_time                :string(255)
#  event_end_date                  :date
#  event_end_time                  :string(255)
#  event_breakoff_code             :integer         not null
#  event_incentive_type_code       :integer         not null
#  event_incentive_cash            :decimal(3, 2)
#  event_incentive_noncash         :string(255)
#  event_comment                   :text
#  transaction_type                :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#

# An Event is a set of one or more scheduled or unscheduled, partially executed or completely executed 
# data collection activities with a single subject. The subject may be a Household or a Participant. 
# All activities in an Event have the same subject.
class Event < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :event_id
  
  belongs_to :participant
  belongs_to :psu,                        :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_type,                 :conditions => "list_name = 'EVENT_TYPE_CL1'",          :foreign_key => :event_type_code,                 :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_disposition_category, :conditions => "list_name = 'EVENT_DSPSTN_CAT_CL1'",    :foreign_key => :event_disposition_category_code, :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_breakoff,             :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :event_breakoff_code,             :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :event_incentive_type,       :conditions => "list_name = 'INCENTIVE_TYPE_CL1'",      :foreign_key => :event_incentive_type_code,       :class_name => 'NcsCode', :primary_key => :local_code

  def to_s
    event_type.display_text
  end
  
  def event_start
    result = "#{event_start_date} #{event_start_time}"
    result = "N/A" if result.blank?
    result
  end
  
  def event_end
    result = "#{event_end_date} #{event_end_time}"
    result = "N/A" if result.blank?
    result
  end

  def self.event_types(events)
    result = []
    events.each do |e| 
      case e
      when "Pregnancy Visit 1"
        result << "Pregnancy Visit  1"
      when "Pre-Pregnancy"
        result << "Pre-Pregnancy Visit"
      else
        result << e
      end
    end
    result
  end

end
