# == Schema Information
# Schema version: 20130409233256
#
# Table name: appointment_sheets
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  updated_at :datetime
#

class AppointmentSheet < ActiveRecord::Base

  attr_reader :person

  def initialize(person)
    @person = Person.find(person)
    @event = @person.participant.pending_events.first if @person.participant.pending_events
  end

  def event_type
    NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', @event.event_type_code).display_text
  end

  def address
    Address.where(:person_id => @person.id,
                  :address_rank_code => 1).first
  end

  def cell_phone
    phone = Telephone.where(:person_id => @person.id,
                            :phone_type_code => 3,
                            :phone_rank_code => 1).first
    phone.phone_nbr.insert(-5, '-').insert(-9, '-') if phone
  end

  def home_phone
    phone = Telephone.where(:person_id => @person.id,
                            :phone_type_code => 1,
                            :phone_rank_code => 1).first
    phone.phone_nbr.insert(-5, '-').insert(-9, '-') if phone
  end

  def participant_full_name
    @person.full_name
  end

  def participant_public_id
    @person.person_id
  end

  def participant_language
    language = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', @person.language_code)
    language.display_text unless @person.language_code == -4
  end

  def mothers_consents
    participant_consents(@person)
  end

  def child_consents
    consents = []
    @person.participant.children.each do |child|
      consents << participant_consents(child)
    end
    consents
  end

  def participant_consents(person)
    consents = []
    ParticipantConsent.where(:participant_id => person.participant.id).all.each do |consent|
      if consent.phase_one?
        case consent.consent_type_code
        when 2
          consents << "Biological"
        when 3
          consents << "Environmental"
        when 4
          consents << "Genetic"
        when 5
          consents << "Birth Samples"
        when 6
          consents << "Child Participation"
        when 7
          consents << "Low Intensity"
        end
      elsif consent.phase_two?
        ParticipantConsentSample.where(:participant_id => person.participant.id).all.each do |sample_consent|
          case sample_consent.sample_consent_type_code
          when 1
            consents << "Environmental"
          when 2
            consents << "Biological"
          when 3
            consents << "Genetic"
          end
        end
      end
    end
    consents.sort
  end
  private :participant_consents

  def child_names
    @person.participant.children.collect(&:full_name)
  end

  def child_sexes
    @person.participant.children.collect(&:sex).collect(&:display_text)
  end

  def child_ages
    ages = []
    @person.participant.children.each do |child|
      ages << age(child.person_dob_date)
    end
    ages
  end

  def age(birth_date)
    today = Date.today
    total_months = (today.year * 12 + today.month) - (birth_date.year * 12 + birth_date.month)
    years, months = total_months.divmod(12)
    strings = [[years, "year"], [months, "month"]].map do |value, unit|
      case value
        when 0 then nil
        when 1 then "#{value} #{unit}"
        else "#{value} #{unit}s"
      end
    end
    strings.compact.join(", ")
  end
  private :age

  def next_event
    the_next_event = @person.participant.pending_events.all.second
    NcsCode.for_list_name_and_local_code('EVENT_TYPE_CL1', the_next_event.event_type_code).display_text if the_next_event
  end

  def children
    @person.children
  end

end
