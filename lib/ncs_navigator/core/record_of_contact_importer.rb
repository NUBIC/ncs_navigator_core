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

      should_create_ppl = person.new_record? && !row[:relationship].blank?
      person.save!

      ParticipantPersonLink.create!(:person => person, :participant => participant, :relationship_code => row[:relationship]) if should_create_ppl

      event = get_event_record(row, participant)
      save_or_report_problems(event, i)
      @last_event = event

      contact = get_contact_record(row, event, person)
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

  def get_person_record(row)
    person = Person.where(:person_id => row[:person_id]).first
    person = Person.new(:person_id => row[:person_id]) if person.blank?
    person.first_name = row[:person_first_name] unless row[:person_first_name].blank?
    person.last_name = row[:person_last_name] unless row[:person_last_name].blank?
    person
  end

  def get_event_record(row, participant)
    start_date =
      if row[:event_start_date]
        start_date = Date.parse(row[:event_start_date])
      elsif @last_event
        @last_event.event_start_date
      end

    event = Event.where(:participant_id => participant.id,
                        :event_type_code => row[:event_type],
                        :event_start_date => start_date).first

    event = Event.new(:participant_id => participant.id,
                      :event_type_code => row[:event_type],
                      :event_start_date => start_date) if event.blank?

    event.participant                     = participant
    event.event_type_other                = row[:event_type_other] unless row[:event_type_other].blank?
    event.disposition                     = row[:disposition] unless row[:disposition].blank?
    event.event_disposition_category_code = row[:event_disposition_category] unless row[:event_disposition_category].blank?
    event.event_start_time                = row[:event_start_time] unless row[:event_start_time].blank?
    event.event_end_date                  = row[:event_end_date] unless row[:event_end_date].blank?
    event.event_end_time                  = row[:event_end_time] unless row[:event_end_time].blank?
    event.event_breakoff_code             = row[:event_breakoff] unless row[:event_breakoff].blank?
    event.event_comment                   = row[:event_comment] unless row[:event_comment].blank?
    event
  end

  def get_contact_record(row, event, person)
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
    contact.contact_type_code       = row[:contact_type] unless row[:contact_type].blank?
    contact.contact_type_other      = row[:contact_type_pther] unless row[:contact_type_pther].blank?
    contact.contact_date            = row[:contact_date] unless row[:contact_date].blank?
    contact.contact_start_time      = row[:contact_start_time] unless row[:contact_start_time].blank?
    contact.contact_end_time        = row[:contact_end_time] unless row[:contact_end_time].blank?
    contact.language_code           = row[:language] unless row[:language].blank?
    contact.language_other          = row[:language_other] unless row[:language_other].blank?
    contact.interpret_code          = row[:interpret] unless row[:interpret].blank?
    contact.interpret_other         = row[:interpret_other] unless row[:interpret_other].blank?
    contact.location_code           = row[:location] unless row[:location].blank?
    contact.location_other          = row[:location_other] unless row[:location_other].blank?
    contact.contact_private_code    = row[:contact_private] unless row[:contact_private].blank?
    contact.who_contacted_code      = row[:who_contacted] unless row[:who_contacted].blank?
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
