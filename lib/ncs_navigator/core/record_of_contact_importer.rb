class NcsNavigator::Core::RecordOfContactImporter

  def initialize(eroc_io, options={})
    @eroc_io = eroc_io
    @errors = []
    @quiet = options.delete(:quiet)
  end

  def csv
    @csv ||= Rails.application.csv_impl.read(@eroc_io, :headers => true, :header_converters => :symbol)
  end

  def import_data
    csv.each_with_index do |row, i|
      next if row.header_row?

      begin
        import_row(row, i)
      rescue => e
        add_error(i, "#{e.class}: #{e}.\n  #{e.backtrace.join("\n  ")}")
      end

      print_status row_progress_message(i)
    end
    print_status "\nRow importing complete.\n"


    unless @errors.empty?
      fail @errors.collect(&:to_s).join("\n")
    end
  end

  def import_row(row, i)
    if participant = Participant.where(:p_id => row[:participant_id]).first
      person = get_person_record(row)

      relationship = extract_coded_value(ParticipantPersonLink, :relationship, row, i)
      should_create_ppl = person.new_record? && relationship
      person.save!

      ParticipantPersonLink.create!(:person => person, :participant => participant, :relationship_code => relationship) if should_create_ppl

      event = get_event_record(row, participant, i)
      save_or_report_problems(event, i)
      @last_event = event

      contact = get_contact_record(row, event, person, i)
      save_or_report_problems(contact, i)

      if contact.valid? && event.valid? # reduce double reporting
        contact_link = get_contact_link_record(row, event, person, contact)
        save_or_report_problems(contact_link, i)
      end
    else
      add_error(i, "Unknown participant #{row[:participant_id].inspect}.")
    end
  end

  def add_error(row_index, message)
    @errors << Error.new(row_index + 1, message)
  end

  def save_or_report_problems(instance, row_index)
    if instance.save
      true
    else
      instance.errors.full_messages.each do |message|
        add_error(row_index, "Invalid #{instance.class}: #{message}.")
      end
    end
  end

  def extract_coded_value(model, coded_attribute, row, row_index)
    if row[coded_attribute]
      value = row[coded_attribute] =~ /^\d+/ ? row[coded_attribute].to_i : row[coded_attribute]
      if legal_codes(model, coded_attribute).include?(value)
        value
      else
        add_error(row_index, "Unknown code value for #{model}##{coded_attribute}: #{value}")
        nil
      end
    end
  end
  private :extract_coded_value

  def apply_coded_value(instance, coded_attribute, row, row_index)
    value = extract_coded_value(instance.class, coded_attribute, row, row_index)
    instance.send("#{coded_attribute}_code=", value) if value
  end

  def legal_codes(model, coded_attribute)
    @legal_codes ||= {}
    @legal_codes["#{model}##{coded_attribute}"] ||= model.ncs_coded_attributes[coded_attribute].code_list.collect(&:local_code)
  end
  private :legal_codes

  def get_person_record(row)
    person = Person.where(:person_id => row[:person_id]).first
    person = Person.new(:person_id => row[:person_id]) if person.blank?
    person.first_name = row[:person_first_name] unless row[:person_first_name].blank?
    person.last_name = row[:person_last_name] unless row[:person_last_name].blank?
    person
  end

  def get_event_record(row, participant, row_index)
    start_date =
      if row[:event_start_date]
        start_date = Date.parse(row[:event_start_date])
      elsif @last_event
        @last_event.event_start_date
      end

    event_type = extract_coded_value(Event, :event_type, row, row_index)

    event = Event.where(:participant_id => participant.id,
                        :event_type_code => event_type,
                        :event_start_date => start_date).first

    event = Event.new(:participant_id => participant.id,
                      :event_type_code => event_type,
                      :event_start_date => start_date) if event.blank?

    event.participant                     = participant
    event.event_type_other                = row[:event_type_other] unless row[:event_type_other].blank?
    event.disposition                     = row[:disposition] unless row[:disposition].blank?
    apply_coded_value(event, :event_disposition_category, row, row_index)
    event.event_start_time                = row[:event_start_time] unless row[:event_start_time].blank?
    event.event_end_date                  = row[:event_end_date] unless row[:event_end_date].blank?
    event.event_end_time                  = row[:event_end_time] unless row[:event_end_time].blank?
    apply_coded_value(event, :event_breakoff, row, row_index)
    event.event_comment                   = row[:event_comment] unless row[:event_comment].blank?
    event
  end

  def get_contact_record(row, event, person, row_index)
    contact_date = Date.parse(row[:contact_date])
    pre_existing_contact = nil

    ContactLink.where(:event_id => event.id, :person_id => person.id).all.each do |cl|
      contact = Contact.where(:id => cl.contact_id).first
      pre_existing_contact = contact if contact.contact_date_date == contact_date &&  contact.contact_start_time == row[:contact_start_time]
      pre_existing_contact
    end

    contact = pre_existing_contact unless pre_existing_contact.nil?
    contact = Contact.new() if contact.blank?

    contact.psu_code                = row[:psu_code] unless row[:psu_code].blank?
    contact.contact_disposition     = row[:contact_disposition] unless row[:contact_disposition].blank?
    apply_coded_value(contact, :contact_type, row, row_index)
    contact.contact_type_other      = row[:contact_type_pther] unless row[:contact_type_pther].blank?
    contact.contact_date            = row[:contact_date] unless row[:contact_date].blank?
    contact.contact_start_time      = row[:contact_start_time] unless row[:contact_start_time].blank?
    contact.contact_end_time        = row[:contact_end_time] unless row[:contact_end_time].blank?
    apply_coded_value(contact, :contact_language, row, row_index)
    contact.contact_language_other  = row[:contact_language_other] unless row[:contact_language_other].blank?
    apply_coded_value(contact, :contact_interpret, row, row_index)
    contact.contact_interpret_other = row[:contact_interpret_other] unless row[:contact_interpret_other].blank?
    apply_coded_value(contact, :contact_location, row, row_index)
    contact.contact_location_other  = row[:contact_location_other] unless row[:contact_location_other].blank?
    apply_coded_value(contact, :contact_private, row, row_index)
    apply_coded_value(contact, :who_contacted, row, row_index)
    contact.contact_comment         = row[:contact_comment] unless row[:contact_comment].blank?
    contact
  end

  def get_contact_link_record(row, event, person, contact)
    contact_link = ContactLink.where(:person_id => person.id, :event_id => event.id, :contact_id => contact.id).first
    contact_link = ContactLink.new(:person => person, :event => event, :contact => contact) if contact_link.blank?

    contact_link.staff_id = row[:staff_id] unless row[:staff_id].blank?
    psu = row[:psu_id].blank? ? contact.psu_code : row[:psu_id]
    contact_link.psu_code = psu

    contact_link
  end

  def row_collecter(row)
    offending_row = []
    row.headers.each{ |h| offending_row << row[h] }
    offending_row
  end

  def row_progress_message(row_index)
    msg = "\r#{row_index + 1}/#{csv.size} processed"
    unless @errors.empty?
      msg << " | #{@errors.size} error#{'s' if @errors.size != 1}"
    end
    msg
  end

  def print_status(message)
    $stderr.print message unless @quiet
  end

  class Error < Struct.new(:row_number, :message)
    def to_s
      "Error on row #{row_number}. #{message}"
    end
  end
end
