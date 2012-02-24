# == Schema Information
# Schema version: 20120222225559
#
# Table name: instruments
#
#  id                       :integer         not null, primary key
#  psu_code                 :integer         not null
#  instrument_id            :string(36)      not null
#  event_id                 :integer
#  instrument_type_code     :integer         not null
#  instrument_type_other    :string(255)
#  instrument_version       :string(36)      not null
#  instrument_repeat_key    :integer
#  instrument_start_date    :date
#  instrument_start_time    :string(255)
#  instrument_end_date      :date
#  instrument_end_time      :string(255)
#  instrument_breakoff_code :integer         not null
#  instrument_status_code   :integer         not null
#  instrument_mode_code     :integer         not null
#  instrument_mode_other    :string(255)
#  instrument_method_code   :integer         not null
#  supervisor_review_code   :integer         not null
#  data_problem_code        :integer         not null
#  instrument_comment       :text
#  transaction_type         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  person_id                :integer
#  survey_id                :integer
#

# An Instrument is a scheduled, partially executed or
# completely executed questionnaire or paper form. An
# Instrument can also be an Electronic Health Record or
# a Personal Health Record.
class Instrument < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :instrument_id
  has_paper_trail

  belongs_to :event
  ncs_coded_attribute :psu,                 'PSU_CL1'
  ncs_coded_attribute :instrument_type,     'INSTRUMENT_TYPE_CL1'
  ncs_coded_attribute :instrument_breakoff, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :instrument_status,   'INSTRUMENT_STATUS_CL1'
  ncs_coded_attribute :instrument_mode,     'INSTRUMENT_ADMIN_MODE_CL1'
  ncs_coded_attribute :instrument_method,   'INSTRUMENT_ADMIN_METHOD_CL1'
  ncs_coded_attribute :supervisor_review,   'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :data_problem,        'CONFIRM_TYPE_CL2'

  belongs_to :person
  belongs_to :survey
  has_one :response_set

  validates_presence_of :instrument_version

  before_create :set_default_codes

  ##
  # Display text from the NcsCode list INSTRUMENT_TYPE_CL1
  # cf. instrument_type belongs_to association
  # @return [String]
  def to_s
    instrument_type.to_s
  end

  def complete?
    !instrument_end_date.blank? && !instrument_end_time.blank? && instrument_status.to_s == "Complete"
  end

  def set_instrument_breakoff(response_set)
    if response_set
      local_code = response_set.has_responses_in_each_section_with_questions? ? 2 : 1
      self.instrument_breakoff = NcsCode.for_attribute_name_and_local_code(:instrument_breakoff_code, local_code)
    end
  end

  ##
  # Given a label from PSC determine the instrument version
  # @param [String] - e.g. ins_que_xxx_int_ehpbhi_p2_v1.0
  # @return [String]
  def self.determine_version(lbl)
    ind = lbl.to_s.rindex("_v")
    lbl[ind + 2, lbl.length]
  end

  ##
  # Given a label from PSC get the part that references the instrument
  # @param[String]
  # @return[String]
  def self.parse_label(lbl)
    return nil if lbl.blank?
    label_marker = "instrument:"
    part = lbl.split.select{ |s| s.include?(label_marker) }.first.to_s
    return nil if part.blank?
    part.gsub(label_marker, "")
  end
  
  def self.surveyor_access_code(lbl)
    Survey.to_normalized_string(Instrument.parse_label(lbl))
  end

  private

    ##
    # Currently this sets the supervisor review and data problem code to No
    # These values can and should be updated by the user/interviewer in case these are not the correct
    # values
    def set_default_codes
      [:supervisor_review, :data_problem, :instrument_mode, :instrument_method].each do |asso|
        current_value = self.send(asso)
        if current_value.nil? || current_value.local_code == -4
          val = NcsCode.for_attribute_name_and_local_code("#{asso}_code".to_sym, 2)
          self.send("#{asso}=", val) if val
        end
      end
    end

end
