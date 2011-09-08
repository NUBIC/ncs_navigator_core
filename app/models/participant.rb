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
  include ActiveModel::Dirty
  include ActiveModel::Validations
  include ActiveModel::Observing
  
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
  has_many :ppg_status_histories, :order => "created_at DESC"
  
  has_many :participant_person_links
  has_many :person_relations, :through => :participant_person_links, :source => :person
  
  validates_presence_of :person
  
  accepts_nested_attributes_for :ppg_details, :allow_destroy => true
  
  scope :in_low_intensity, where("high_intensity is null or high_intensity is false")
  scope :in_high_intensity, where("high_intensity is true")
  
  delegate :age, :first_name, :last_name, :person_dob, :gender, :upcoming_events, :contact_links, :to => :person
  
  ##
  # State Machine used to manage relationship with Patient Study Calendar
  state_machine :initial => :pending do
    before_transition :log_state_change
    after_transition :on => :enroll_in_high_intensity_arm, :do => :switch_arm


    event :register do
      transition :pending => :registered
    end

    # TODO: determine if this is necessary
    # state :in_pregnancy_probability_group do
    #   validates_presence_of :ppg_status
    # end

    event :assign_to_pregnancy_probability_group do
      transition :registered => :in_pregnancy_probability_group
    end

    event :impregnate do
      transition :in_pregnancy_probability_group => :pregnant
    end
    
    event :enroll_in_high_intensity_arm do
      transition :in_pregnancy_probability_group => :in_high_intensity_arm, :pregnant => :in_high_intensity_arm
    end
    
    event :non_pregnant_consent do
      transition :in_high_intensity_arm => :pre_pregnancy
    end
    
    event :pregnant_consent do
      transition :in_high_intensity_arm => :pregnancy_one
    end
    
    # event :pregnancy_one_visit do
    #   transition :pregnancy_one => :pregnancy_two
    # end
    # 
    # event :birth_child do
    #   transition :pregnancy_one => :birth, :pregnancy_two => :birth
    # end
    # 
    # event :three_months_after_birth do
    #   transition :birth => :three_month
    # end

  end
  
  ##
  # Log each time the Participant changes state 
  # cf. state_machine above
  def log_state_change(transition)
    event, from, to = transition.event, transition.from_name, transition.to_name
    Rails.logger.info("Participant State Change #{id}: #{from} => #{to} on #{event}")
  end
  
  ##
  # The current pregnancy probability group status for this participant. 
  # 
  # This is determined either by the first assigned status from the ppg_details relationship
  # or from the most recent ppg_status_histories record. 
  # Each participant will be associated with a ppg_details record when first screened and 
  # will have a ppg_status_histories association after the first follow-up. There is a good 
  # chance that the ppg_status_histories record will be created in tandem with the ppg_details
  # when first screened, but this cannot be assured.
  #
  # The big difference between the two is that the ppg_detail status comes from the PPG_STATUS_CL2
  # code list whereas the ppg_status_history status comes from the PPG_STATUS_CL1 code list.
  #
  # 1 - PPG Group 1: Pregnant and Eligible 
  # 2 - PPG Group 2: High Probability – Trying to Conceive
  # 3 - PPG Group 3: High Probability – Recent Pregnancy Loss 
  # 4 - PPG Group 4: Other Probability – Not Pregnancy and not Trying
  # 5 - PPG Group 5: Ineligible (Unable to Conceive, age-ineligible)
  # 6 or nil - PPG: Group 6: Withdrawn
  # 6 or 7 - Ineligible Dwelling Unit
  #
  # @return [NcsCode]
  def ppg_status
    ppg_status_histories.blank? ? ppg_details.first.ppg_first : ppg_status_histories.first.ppg_status
  end
    
  ##
  # The next segment in PSC for the participant
  # based on the current state, pregnancy probability group, and protocol arm
  # 
  # @return [String]
  def next_study_segment
    if low_intensity?
      next_low_intensity_study_segment
    else
      next_high_intensity_study_segment
    end
  end
  
  def last_event_date
    contact_links.blank? ? self.created_at.to_date : contact_links.first.created_at.to_date
  end
  
  ##
  # The next event for the participant with the date and the event name
  # @return [ScheduledEvent]
  def next_scheduled_event
    ScheduledEvent.new(:date => last_event_date + interval, :event => upcoming_events.first)
  end
  
  ##
  # Based on the current state, pregnancy probability group, and 
  # the intensity group (hi/lo) determine the next event
  # @return [String]
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
  
  ##
  # Display text from the NcsCode list PARTICIPANT_TYPE_CL1 
  # cf. p_type belongs_to association
  # @return [String]
  def participant_type
    p_type.to_s
  end
  
  ##
  # The number of months to wait before the next Follow-Up event
  # @return [Date]
  def interval
    low_intensity? ? 6.months : 3.months
  end
  
  ##
  # @return [true,false]
  def low_intensity?
    !high_intensity
  end
  
  ##
  # Helper method to switch from lo intensity to hi intensity protocol and vice-versa
  # @return [true, false]
  def switch_arm
    self.high_intensity = !self.high_intensity
    self.save
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
  
  ##
  # Find all Participants for the given pregnancy probability group
  # @param local_code for NcsCode
  # @return[Array<Participant>]
  def self.in_ppg_group(local_code)
    results = []
    results << Participant.joins(:ppg_status_histories).where("ppg_status_histories.ppg_status_code = ?", local_code).all.select { |par| par.ppg_status.local_code == local_code }
    results << Participant.joins(:ppg_details).where("ppg_details.ppg_first_code = ?", local_code).all.select { |par| par.ppg_status.local_code == local_code }
    results.flatten.uniq
  end
  
  private
  
    def relationships(code)
      participant_person_links.select { |ppl| ppl.relationship.local_code == code }.collect { |ppl| ppl.person } 
    end
    
    def next_low_intensity_study_segment
      if pending?
        nil
      elsif registered?
        "LO-Intensity: Pregnancy Screener"
      elsif in_pregnancy_probability_group?
        if [1,2].include? ppg_status.local_code
          "LO-Intensity: PPG 1 and 2"
        elsif [3,4].include? ppg_status.local_code
          "LO-Intensity: PPG Follow Up"
        end
      elsif pregnant?
        "LO-Intensity: Birth Visit Interview"
      else
        nil
      end
    end
  
    def next_high_intensity_study_segment
      if in_high_intensity_arm?
        "HI-Intensity: HI-LO Conversion"
      elsif pre_pregnancy?
        "HI-Intensity: Pre-Pregnancy"
      else
        nil
      end
    end
  
end
