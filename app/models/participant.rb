# == Schema Information
# Schema version: 20110823212243
#
# Table name: participants
#
#  id                       :integer         not null, primary key
#  psu_code                 :string(36)      not null
#  p_id                     :binary          not null
#  person_id                :integer         not null
#  p_type_code              :integer         not null
#  p_type_other             :string(255)
#  status_info_source_code  :integer         not null
#  status_info_source_other :string(255)
#  status_info_mode_code    :integer         not null
#  status_info_mode_other   :string(255)
#  status_info_date         :date
#  enroll_status_code       :integer         not null
#  enroll_date              :date
#  pid_entry_code           :integer         not null
#  pid_entry_other          :string(255)
#  pid_age_eligibility_code :integer         not null
#  pid_comment              :text
#  transaction_type         :string(36)
#  created_at               :datetime
#  updated_at               :datetime
#  being_processed          :boolean
#  high_intensity           :boolean
#

# A Participant is a living Person who has provided Study data about her/himself or a NCS Child. 
# S/he may have been administered a variety of questionnaires or assessments, including household enumeration, 
# pregnancy screener, pregnancy questionnaire, etc. Once born, NCS-eligible babies are assigned Participant IDs.  
# Every Participant is also a Person. People do not become Participants until they are determined eligible for a pregnancy screener.
class Participant < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :p_id

  belongs_to :person
  belongs_to :psu,                  :conditions => "list_name = 'PSU_CL1'",                 :foreign_key => :psu_code,                  :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :p_type,               :conditions => "list_name = 'PARTICIPANT_TYPE_CL1'",    :foreign_key => :p_type_code,               :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :status_info_source,   :conditions => "list_name = 'INFORMATION_SOURCE_CL4'",  :foreign_key => :status_info_source_code,   :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :status_info_mode,     :conditions => "list_name = 'CONTACT_TYPE_CL1'",        :foreign_key => :status_info_mode_code,     :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :enroll_status,        :conditions => "list_name = 'CONFIRM_TYPE_CL2'",        :foreign_key => :enroll_status_code,        :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pid_entry,            :conditions => "list_name = 'STUDY_ENTRY_METHOD_CL1'",  :foreign_key => :pid_entry_code,            :class_name => 'NcsCode', :primary_key => :local_code
  belongs_to :pid_age_eligibility,  :conditions => "list_name = 'AGE_ELIGIBLE_CL2'",        :foreign_key => :pid_age_eligibility_code,  :class_name => 'NcsCode', :primary_key => :local_code
  
  has_many :ppg_details
  has_many :ppg_status_histories, :order => "ppg_status_date DESC"
  
  has_many :participant_person_links
  has_many :person_relations, :through => :participant_person_links, :source => :person
  
  validates_presence_of :person
  
  scope :in_low_intensity, where("high_intensity is null or high_intensity is false")
  scope :in_high_intensity, where("high_intensity is true")
  
  delegate :age, :first_name, :last_name, :person_dob, :gender, :upcoming_events, :contact_links, :to => :person
  
  def self.in_ppg_group(local_code)
    Participant.joins(:ppg_status_histories).where("ppg_status_histories.ppg_status_code = ?", local_code).all.select { |par| par.ppg_status.local_code == local_code }
  end
  
  def ppg_status
    ppg_status_histories.blank? ? ppg_details.first.ppg_first : ppg_status_histories.first.ppg_status
  end
  
  def next_scheduled_event
    ScheduledEvent.new(:date => last_event_date + interval, :event => upcoming_events.first)
  end
  
  def last_event_date
    contact_links.blank? ? self.created_at.to_date : contact_links.first.created_at.to_date
  end

  def interval
    in_low_intensity_arm? ? 6.months : 3.months
  end
  
  def in_low_intensity_arm?
    !high_intensity
  end
  
  def upcoming_events
    events = []
    # TODO: do not hard code NcsCode local code here
    case ppg_status.local_code
    when 1
      events << "Pregnancy Visit 1"
    when 2
      events << "Pre-Pregnancy"
    when 3,4
      events << "Pregnancy Probability"
    end
    events
  end
  
  def participant_type
    p_type.to_s
  end
  
  def father
    # TODO: do not hard code NcsCode local code here
    relationships(4).first
  end
  
  def children
    # TODO: do not hard code NcsCode local code here
    relationships(8)
  end

  def mother
    # TODO: do not hard code NcsCode local code here
    relationships(2).first
  end
  
  def partner
    # TODO: do not hard code NcsCode local code here
    relationships(7).first    
  end
  
  private
  
    def relationships(code)
      participant_person_links.select { |ppl| ppl.relationship.local_code == code }.collect { |ppl| ppl.person } 
    end
  
end
