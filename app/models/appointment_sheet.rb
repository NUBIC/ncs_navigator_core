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
    return nil if phone.nil?
    if phone.phone_nbr =~ /-/
      return phone.phone_nbr
    end
    phone.phone_nbr.insert(-5, '-').insert(-9, '-') if phone
  end

  def home_phone
    phone = Telephone.where(:person_id => @person.id,
                            :phone_type_code => 1,
                            :phone_rank_code => 1).first
    return nil if phone.nil?
    if phone.phone_nbr =~ /-/
      return phone.phone_nbr
    end
    phone.phone_nbr.insert(-5, '-').insert(-9, '-') if phone
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
    return nil if person.participant.nil?
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

  def child_due_dates
    child_dobs.map do |bd|
      due_date_in_range_of_birth_date(Date.parse(bd))
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
    @person.participant.children.collect { |c| c.person_dob_date.strftime('%Y-%m-%d') }
  end
  private :child_dobs

  def child_birth_dates
    @person.participant.children.collect { |c| c.person_dob_date.strftime('%m/%d/%Y') }
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

end
