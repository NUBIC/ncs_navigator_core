# -*- coding: utf-8 -*-


# In addition to the single time consents we have participants review and give oral consent to specific
# data collection components that occur at a specific visit. These are presented on what is called the
# Visit Information Sheet or VIS. The VIS is specific to a specific Event and needs to be linked back to
# that. Also, multiple activities (instruments/specimens, etc) are represented on a VIS so we need to
# isolate out consent or dissent for each activity. Each row of the Participant Visit Consent table is
# a unique consent given at a specific component at a specific visit
class ParticipantVisitConsent < ActiveRecord::Base
  include MdesRecord
  acts_as_mdes_record :public_id_field => :pid_visit_consent_id

  belongs_to :participant
  belongs_to :contact
  belongs_to :vis_person_who_consented,  :class_name => "Person", :foreign_key => :vis_person_who_consented_id

  ncs_coded_attribute :psu,                  'PSU_CL1'
  ncs_coded_attribute :vis_consent_type,     'VISIT_TYPE_CL1'
  ncs_coded_attribute :vis_consent_response, 'CONFIRM_TYPE_CL2'
  ncs_coded_attribute :vis_language,         'LANGUAGE_CL2'
  ncs_coded_attribute :vis_who_consented,    'AGE_STATUS_CL1'
  ncs_coded_attribute :vis_translate,        'TRANSLATION_METHOD_CL1'

  ##
  # For the VISIT_TYPE_CL1 code list, returns the value and text
  # for each item in the code list (other than Missing in Error)
  # @return [Array<id, label>]
  def self.visit_types
    NcsNavigatorCore.mdes.types.find { |t| t.name == 'visit_type_cl1' }.
      code_list.collect { |cl| [cl.value, cl.label.to_s.strip] }.
      select { |c| c[0] != "-4" }
  end

  ##
  # A collection of all event type codes for events in which
  # a Visit Information Sheet (VIS) is presented
  # The events are:
  #   11 - Pre-Pregnancy Visit
  #   13 - Pregnancy Visit 1
  #   15 - Pregnancy Visit 2
  #   18 - Birth
  #   19 - Father
  #   24 - 6-Month
  #   27 - 12-Month
  #   33 - Low Intensity Data Collection
  # @return [Array<String>]
  def self.event_types_with_visit_information_sheets
    ['11', '13', '15', '18', '19', '24', '27', '33']
  end

  ##
  # Given an Event, return whether or not a Visit Information Sheet
  # was presented at the Event
  def self.visit_information_sheet_presented?(event)
    event_types_with_visit_information_sheets.include? event.try(:event_type_code).to_s
  end

end

