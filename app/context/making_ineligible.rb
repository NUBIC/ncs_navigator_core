class MakingIneligible

  def self.make_ineligible(response_set)
    MakingIneligible.new(response_set).make_ineligible
  end

  attr_reader :person, :participant, :response_set

  def initialize(response_set)
    @person = response_set.person
    @participant = response_set.participant
    @response_set = response_set
    @ineligibilifier = Ineligibilifier.new.extend Ineligible
  end

  def make_ineligible
    @ineligibilifier.delete_participant_person_links(@person, @participant)
    @ineligibilifier.disassociates_participant_from_all_events(@participant)
    @ineligibilifier.disassociates_participant_from_response_set(@response_set)
    @ineligibilifier.creates_ineligibility_record(@participant)
  end

  module Ineligible

    def delete_participant_person_links(person, participant)
      ParticipantPersonLink.where(:participant_id => participant, :person_id => person).all.each { |e| e.delete}
    end

    def disassociates_participant_from_all_events(participant)
      Event.where( :participant_id => participant.id ).all.map { |e| e.update_attribute(:participant_id, nil) }
    end

    def disassociates_participant_from_response_set(response_set)
      response_set.participant = nil
    end

    def creates_ineligibility_record(participant)
      SampledPersonsIneligibility.create_from_participant!(participant)
    end
  end
end

class Ineligibilifier; end
