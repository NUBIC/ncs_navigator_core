# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130314152336
#
# Table name: response_sets
#
#  access_code                               :string(255)
#  api_id                                    :string(255)
#  completed_at                              :datetime
#  created_at                                :datetime
#  id                                        :integer          not null, primary key
#  instrument_id                             :integer
#  non_interview_report_id                   :integer
#  participant_consent_id                    :integer
#  participant_id                            :integer
#  processed_for_operational_data_extraction :boolean
#  started_at                                :datetime
#  survey_id                                 :integer
#  updated_at                                :datetime
#  user_id                                   :integer
#

class ResponseSet < ActiveRecord::Base
  include NcsNavigator::Core::Surveyor::HasPublicId
  include ResponseSetPrepopulation
  include Surveyor::Models::ResponseSetMethods

  belongs_to :person, :foreign_key => :user_id, :class_name => 'Person', :primary_key => :id
  belongs_to :participant, :inverse_of => :response_sets

  # DO NOT CREATE ANY OF THESE ASSOCIATIONS UNLESS YOU KNOW WHAT THEY MEAN
  belongs_to :instrument, :inverse_of => :response_sets
  belongs_to :participant_consent, :inverse_of => :response_set
  belongs_to :non_interview_report, :inverse_of => :response_set

  after_save :extract_operational_data

  attr_accessible :participant_id

  def extract_operational_data
    OperationalDataExtractor::Base.process(self) if complete?
  end

  ##
  # Prepopulates this response set.
  #
  # This method does not save generated responses.  Use {#save} for that.
  def prepopulate
    populators_for(self).each(&:run)
  end

  ##
  # Responses in the response set that are targeted for Mustache context helper
  # questions.
  def mustache_helper_responses
    # The reorder(nil) is a hack to work around overly-broad default orders in
    # Surveyor.
    responses.reorder(nil).merge(Question.for_mustache_helpers)
  end

  ##
  # Generates a Mustache context from this ResponseSet.
  def to_mustache
    Mustache.new(self)
  end

  def has_responses_in_each_section_with_questions?
    result = false
    survey.sections_with_questions.each do |section|
      section_questions = section.questions.select { |q| !q.answers.blank? }
      next if section_questions.blank?

      # There is a section with questions who has no answered questions
      if section_questions.select { |q| is_answered?(q) }.count == 0
        result = false
        break
      else
        result = true
      end
    end
    result
  end

  def as_json(options = nil)
    super.merge({
      'p_id' => participant.try(:public_id),
      'person_id' => person.try(:public_id)
    })
  end

  ##
  # This ResponseSet may or may not be part of a multi-part Survey.
  # This method returns itself and all ResponseSets associated with
  # the Instrument class. If this ResponseSet is associated with a
  # ParticipantConsent record, then this method will return an Array
  # with one element, itself (since the ParticipantConsent and
  # NonInterviewReport ResponseSets are not multi-part).
  # @return [Array<ReponseSet>]
  def associated_response_sets
    instrument_associated? ? instrument.response_sets : [self]
  end

  ##
  # The ResponseSet is associated with a contact link through
  # the Instrument, ParticipantConsent, or Non-Interview Report.
  # Determine the MDES associated class and act accordingly to
  # get the ContactLink record.
  # @return [ContactLink]
  def contact_link
    if instrument_associated?
      instrument.contact_link
    elsif contact
      contact.contact_links.first
    end
  end

  ##
  # Return the Contact associated with the associated
  # MDES record to this ResponseSet.
  #
  # This is only used in the contact_link method above.
  #
  # @return [Contact]
  def contact
    if participant_consent_associated?
      participant_consent.contact
    elsif non_interview_report_associated?
      non_interview_report.contact
    elsif instrument_associated?
      instrument.contact_link.contact
    end
  end
  private :contact

  ##
  # Similar to the contact method, this returns the Event
  # associated with the MDES record associated with the
  # ResponseSet.
  #
  # @see surveyor_controller#set_activity_plan_for_participant
  # @return [Event]
  def event
    contact_link.try(:event)
  end

  ##
  # True if the NonInterviewReport association exists.
  # @return [Boolean]
  def non_interview_report_associated?
    !non_interview_report.blank?
  end

  ##
  # True if the ParticipantConsent association exists.
  # @return [Boolean]
  def participant_consent_associated?
    !participant_consent.blank?
  end

  ##
  # True if the Instrument association exists.
  # @return [Boolean]
  def instrument_associated?
    !instrument.blank?
  end

  ##
  # A Mustache-like object that derives all of its context from a response set.
  #
  # @private
  class Mustache < ::Mustache
    def initialize(rs)
      rs.mustache_helper_responses.each do |r|
        self[r.question.reference_identifier.sub('helper_', '')] = r.value
      end
    end
  end
end
