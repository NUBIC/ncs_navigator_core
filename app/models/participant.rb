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
  accepts_nested_attributes_for :ppg_status_histories, :allow_destroy => true
  
  scope :in_low_intensity, where("high_intensity is null or high_intensity is false")
  scope :in_high_intensity, where("high_intensity is true")
  
  delegate :age, :first_name, :last_name, :person_dob, :gender, :upcoming_events, :contact_links, :current_contact_link, :instruments, :start_instrument, :started_survey, :instrument_for, :to => :person
  
  ##
  # State Machine used to manage relationship with Patient Study Calendar
  state_machine :low_intensity_state, :initial => :pending do
    before_transition :log_state_change
    after_transition :on => :enroll_in_high_intensity_arm, :do => :add_to_high_intensity_protocol

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

    event :low_intensity_consent do
      transition :in_pregnancy_probability_group => :consented_low_intensity
    end

    event :impregnate do
      transition :in_pregnancy_probability_group => :pregnant_and_consented, :consented_low_intensity => :pregnant_and_consented
    end
    
    event :enroll_in_high_intensity_arm do
      transition :in_pregnancy_probability_group => :moved_to_high_intensity_arm, :pregnant_and_consented => :moved_to_high_intensity_arm
    end

    event :low_intensity_birth do
      transition :pregnant_and_consented => :birth_low
    end
    
    

  end
  
  state_machine :high_intensity_state, :initial => :in_high_intensity_arm do
    before_transition :log_state_change
    
    event :consent do
      transition :in_high_intensity_arm => :consented_high_intensity
    end
    
    event :non_pregnant_informed_consent do
      transition :consented_high_intensity => :pre_pregnancy
    end
    
    event :pregnant_informed_consent do
      transition :consented_high_intensity => :pregnancy_one
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
  # Helper method to get the current state of the Participant
  # Since there are two state_machines (one for Low Intensity and one for High (or PB or EH))
  # this will return the current state based on which arm the Participant is enrolled in
  # @return [String]
  def state
    if low_intensity?
      low_intensity_state
    else
      high_intensity_state
    end
  end
  
  
  ##
  # Helper method to set the current state of the Participant
  # Since there are two state_machines (one for Low Intensity and one for High (or PB or EH))
  # this will update the state based on which arm the Participant is enrolled in
  # @param [String]
  def state=(state)
    if low_intensity?
      low_intensity_state = state
    else
      high_intensity_state = state
    end
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
    events << next_study_segment if next_study_segment
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
    if low_intensity? or recent_loss?
      6.months
    else
      3.months
    end
  end
  
  ##
  # Only Participants who are Pregnant or Trying to become pregnant 
  # should be presented with the consent form, otherwise they should be ineligible
  # or simply following
  def can_consent?
    pregnant_or_trying?
  end
  
  ##
  # Participants who are eligible for the protocol but not actively trying nor pregnant
  # should be followed to see if they ever move to the 'can_consent' state
  def following?
    eligible_for_ppg_follow_up?
  end
  
  ##
  # Participants are known to be pregnant if in the proper Pregnancy Probability Group
  def known_to_be_pregnant?
    pregnant?
  end
  
  ##
  # @return [true,false]
  def low_intensity?
    !high_intensity
  end
  
  def add_to_high_intensity_protocol
    switch_arm(true)
  end
  
  ##
  # Helper method to switch from lo intensity to hi intensity protocol and vice-versa
  # @return [true, false]
  def switch_arm(ensure_high_intensity = false)
    val = ensure_high_intensity ? true : !self.high_intensity
    self.high_intensity = val
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

  ##
  # Temporary helper method to assist in reverting state during development
  # TODO: delete me
  def unregister
    self.state = "pending"
    self.save!
  end
  
  ##
  # Temporary helper method to assist in reverting state during development
  # TODO: delete me
  def remove_from_pregnancy_probability_group
    self.state = "registered"
    self.save!
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
        lo_intensity_follow_up
      elsif consented_low_intensity?
        lo_intensity_follow_up
      elsif pregnant?
        "LO-Intensity: Birth Visit Interview"
      else
        nil
      end
    end
  
    def next_high_intensity_study_segment
      if registered?
        switch_arm if high_intensity? # Participant should not be in the high intensity arm if now just registering
        "LO-Intensity: Pregnancy Screener"
      elsif in_high_intensity_arm?
        eligible_for_ppg_follow_up? ? hi_intensity_follow_up : "HI-Intensity: HI-LO Conversion"
      elsif consented_high_intensity?
        hi_intensity_follow_up
      elsif pre_pregnancy?
        "HI-Intensity: Pre-Pregnancy"
      elsif pregnancy_one?
        "HI-Intensity: Pregnancy Visit 1"
      elsif in_pregnancy_probability_group?
        hi_intensity_follow_up
      else
        nil
      end
    end
    
    def lo_intensity_follow_up
      return nil if ineligible?
      can_consent? ? "LO-Intensity: PPG 1 and 2" : "LO-Intensity: PPG Follow Up"
    end
    
    def hi_intensity_follow_up
      recent_loss? ? "HI-Intensity: PPG Follow Up CATI after 6 months" : "HI-Intensity: PPG Follow Up CATI after 3 months"
    end
    
    def pregnant_or_trying?
      [1,2].include?(ppg_status.local_code)
    end
    
    def eligible_for_ppg_follow_up?
      [3,4].include?(ppg_status.local_code)
    end
    
    def ineligible?
      ppg_status.local_code > 4
    end
    
    def pregnant?
      ppg_status.local_code == 1
    end
  
    def recent_loss?
      ppg_status.local_code == 3
    end
  
end
