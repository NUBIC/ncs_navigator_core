# == Schema Information
# Schema version: 20130409233256
#
# Table name: appointment_sheets
#
#  created_at :datetime
#  id         :integer          not null, primary key
#  updated_at :datetime
#

class AppointmentSheet
  include ActionView::Helpers::TextHelper

  attr_reader :person

  def initialize(person, date)
    @person = person
    @event = @person.participant.pending_events.first if @person.participant && @person.participant.pending_events
    @date = date
  end

  def event_type
    return "Unknown Event" if @event.blank?
    @event.event_type.display_text
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

    consents = ParticipantConsent.where(:participant_id => person.participant.id)
                                 .includes(:participant_consent_samples).all
    return [] if consents.first.nil?
    if consents.first.phase_one?
      consents.collect { |consent| consent_print(consent.consent_type.display_text) }
    else
      general_consent = ["General"]
      general_consent + consents.first.participant_consent_samples.collect { |consent| consent_print(consent.sample_consent_type.display_text) }
    end
  end
  private :participant_consents

  def consent_print(text)
    if text =~ /^Consent to collect (.*)$/
      /^Consent to collect (.*)$/.match(text).captures.first.titleize
    else
      text.sub(" consent","").titleize
    end
  end
  private :consent_print

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
    total_months = (@date.year * 12 + @date.month) - (birth_date.year * 12 + birth_date.month)
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
    last_contact = all_contacts.uniq.sort_by(&:contact_date_date).last
    last_contact.contact_comment unless last_contact.blank?
  end

end
