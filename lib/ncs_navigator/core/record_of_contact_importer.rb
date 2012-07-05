class RecordOfContactImporter

  CSV_DATE_FORMAT = '%m/%d/%Y'

  def self.import_data(contact_record_file)
    Rails.application.csv_impl.parse(contact_record_file, :headers => true, :header_converters => :symbol) do |row|
      next if row.header_row?

      if participant = Participant.where(:p_id => row[:participant_id]).first
        person = get_person_record(row)

        should_create_ppl = person.new_record? && !row[:relationship].blank?
        person.save!

        ParticipantPersonLink.create!(:person => person, :participant => participant, :relationship_code => row[:relationship]) if should_create_ppl

        event = get_event_record(row, participant)
        event.save!

        contact = get_contact_record(row, event, person)
        contact.save!

        contact_link = get_contact_link_record(row, event, person, contact)

        if contact_link.valid?
          contact_link.save!
        else
          File.open(contact_link_import_error_log, 'a') { |f| f.write("[#{Time.now.to_s(:db)}] contact_link record invalid for - #{row_collecter(row).join(',')} - #{contact_link.errors.map(&:to_s)}\n") }
        end
      else
        File.open(contact_link_missing_participant_log, 'a') { |f| f.write("[#{Time.now.to_s(:db)}] contact_link record error: -> participant [#{row[:participant_id]}] missing in row - #{row_collecter(row).join(',')}\n") }
      end
    end
  end

  def self.contact_link_import_error_log
    dir = "#{Rails.root}/log/contact_link_import_error_logs"
    FileUtils.makedirs(dir) unless File.exists?(dir)
    log_path = "#{dir}/#{Date.today.strftime('%Y%m%d')}_import_errors.log"
    File.open(log_path, 'w') {|f| f.write("[#{Time.now.to_s(:db)}] \n\n") } unless File.exists?(log_path)
    log_path
  end

  def self.contact_link_missing_participant_log
    dir = "#{Rails.root}/log/contact_link_missing_participant_logs"
    FileUtils.makedirs(dir) unless File.exists?(dir)
    log_path = "#{dir}/#{Date.today.strftime('%Y%m%d')}_missing_participant.log"
    File.open(log_path, 'w') {|f| f.write("[#{Time.now.to_s(:db)}] \n\n") } unless File.exists?(log_path)
    log_path
  end

  def self.get_person_record(row)
    person = Person.where(:person_id => row[:person_id]).first
    person = Person.new(:person_id => row[:person_id]) if person.blank?
    person.first_name = row[:person_first_name] unless row[:person_first_name].blank?
    person.last_name = row[:person_last_name] unless row[:person_last_name].blank?
    person
  end

  def self.get_event_record(row, participant)
    start_date = Date.strptime(row[:event_start_date], CSV_DATE_FORMAT)

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
    event.event_breakoff_code             = row[:event_breakoff] unless row[:event_breakoff].blank?
    event.event_comment                   = row[:event_comment] unless row[:event_comment].blank?
    event
  end

  def self.get_contact_record(row, event, person)
    contact_date = Date.strptime(row[:contact_date], CSV_DATE_FORMAT)
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

  def self.get_contact_link_record(row, event, person, contact)
    contact_link = ContactLink.where(:person_id => person.id, :event_id => event.id, :contact_id => contact.id).first
    contact_link = ContactLink.new(:person => person, :event => event, :contact => contact) if contact_link.blank?

    contact_link.staff_id = row[:staff_id] unless row[:staff_id].blank?
    psu = row[:psu_id].blank? ? contact.psu_code : row[:psu_id]
    contact_link.psu_code = psu

    contact_link
  end

  def self.row_collecter(row)
    offending_row = []
    row.headers.each{ |h| offending_row << row[h] }
    offending_row
  end
end
