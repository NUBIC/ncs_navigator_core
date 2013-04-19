# == Schema Information
# Schema version: 20130409233256
#
# Table name: appointment_sheets
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  updated_at :datetime
#
include ActionView::Helpers::TextHelper

class AppointmentSheet

  attr_reader :person

  def initialize(person)
    @person = Person.find(person)
    @event = @person.participant.pending_events.first if @person.participant && @person.participant.pending_events
  end

  def event_type
    return "Unknown Event" if @event.nil?
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
    phone.dashed if phone
  end

  def home_phone
    phone = Telephone.where(:person_id => @person.id,
                            :phone_type_code => 1,
                            :phone_rank_code => 1).first
    phone.dashed if phone
  end

  def participant_full_name
    @person.full_name
  end

  def participant_public_id
    @person.participant.p_id
  end

  def participant_language
    language = NcsCode.for_list_name_and_local_code('LANGUAGE_CL2', @person.language_code)
    language.display_text unless @person.language_code == -4
  end

  def mothers_consents
    participant_consents(@person)
  end

  def child_consents
    @person.participant.children.collect { |c| participant_consents(c) }
  end

  def participant_consents(person)
    return [] if person.participant.nil?

    general_consents = ParticipantConsent.where(:participant_id => person.participant.id).all
    return [] if general_consents.first.nil?
    if general_consents.first.phase_one?
      general_conserts.collect { |consent| participant_consents_phase_one(consent.consent_type_code) }
    else
      sample_consents = ParticipantConsentSample.where(:participant_id => person.participant.id).all
      sample_consents.collect  { |consent| participant_consents_phase_two(consent.sample_consent_type_code) }
    end
  end
  private :participant_consents

  def participant_consents_phase_one(type_code)
    case type_code
    when 2
      "Biological"
    when 3
      "Environmental"
    when 4
      "Genetic"
    when 5
      "Birth Samples"
    when 6
      "Child Participation"
    when 7
      "Low Intensity"
    end
  end
  private :participant_consents_phase_one

  def participant_consents_phase_two(type_code)
    case type_code
    when 1
      "Environmental"
    when 2
      "Biological"
    when 3
      "Genetic"
    end
  end
  private :participant_consents_phase_two

  def child_names
    @person.participant.children.collect(&:full_name)
  end

  def child_due_dates
    child_dobs.map do |bd|
      due_date_in_range_of_birth_date(Date.parse(bd)) if bd
    end
  end

  def due_date_in_range_of_birth_date(birth_date)
    ppg_details = PpgDetail.where(:participant_id => @person.participant).all
    return nil if ppg_details.nil?

    min_date = birth_date - 5.months
    max_date = birth_date + 2.months

    date = ppg_details.find do |ppg|
      (Date.parse(ppg.due_date) > min_date &&  Date.parse(ppg.due_date) < max_date) if ppg.due_date
    end
    Date.parse(date.due_date).strftime('%m/%d/%Y') if date
  end
  private :due_date_in_range_of_birth_date

  def child_dobs
    @person.participant.children.collect { |c| c.person_dob_date.strftime('%Y-%m-%d') if c.person_dob_date }
  end
  private :child_dobs

  def child_birth_dates
    @person.participant.children.collect { |c| c.person_dob_date.strftime('%m/%d/%Y') if c.person_dob_date }
  end

  def child_sexes
    sexes = @person.participant.children.collect(&:sex).collect(&:display_text)
    sexes.map { |sex| sex == 'Missing in Error' ? nil : sex }
  end

  def child_ages
    @person.participant.children.collect { |c| age(c.person_dob_date) unless c.person_dob.nil? }
  end

  def age(birth_date)
    today = Time.zone.today
    total_months = (today.year*12 + today.month) - (birth_date.year*12 + birth_date.month)
    years, months = total_months.divmod(12)
    strings = [[years, "year"], [months, "month"]].map do |value, unit|
      value > 0 ? [pluralize(value, unit)] : nil
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

  def last_contact_comment
    contacts_connected_to_person = ContactLink.where(:person_id => @person.id).all.collect(&:contact)
    contacts_connected_to_participant = ContactLink.joins(:event).where("events.participant_id = ?", @person.participant.id).collect(&:contact)
    all_contacts = contacts_connected_to_person + contacts_connected_to_participant
    return nil unless all_contacts.all?(&:contact_date_date)
    all_contacts.uniq.sort_by(&:contact_date_date).last.contact_comment
  end

end
