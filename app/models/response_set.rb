# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20130301164426
#
# Table name: response_sets
#
#  access_code                               :string(255)
#  api_id                                    :string(255)
#  completed_at                              :datetime
#  created_at                                :datetime
#  id                                        :integer          not null, primary key
#  instrument_id                             :integer
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
  include Surveyor::Models::ResponseSetMethods
  belongs_to :person, :foreign_key => :user_id, :class_name => 'Person', :primary_key => :id
  belongs_to :instrument, :inverse_of => :response_sets
  belongs_to :participant, :inverse_of => :response_sets
  belongs_to :participant_consent, :inverse_of => :response_set

  after_save :extract_operational_data

  attr_accessible :participant_id

  def extract_operational_data
    OperationalDataExtractor::Base.process(self) if complete?
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
  # with one element, itself (since the ParticipantConsent ResponseSets
  # are not multi-part).
  # @return [Array<ReponseSet>]
  def associated_response_sets
    instrument_associated? ? instrument.response_sets : [self]
  end

  ##
  # The ResponseSet is associated with a contact link through
  # the Instrument or ParticipantConsent.
  # Determine the MDES associated class and act accordingly to
  # get the ContactLink record.
  # @return [ContactLink]
  def contact_link
    instrument_associated? ? instrument.contact_link : participant_consent.contact.contact_links.first
  end

  ##
  # True if the Instrument association exists.
  # @return [Boolean]
  def instrument_associated?
    !instrument.blank?
  end

end
