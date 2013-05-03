class NcsNavigator::Core::RecordOfContactImporter
  def initialize(eroc_io, options={})
    @eroc_io = eroc_io
    @errors = []
    @quiet = options.delete(:quiet)

    psc = options.delete(:psc)
    if psc
      import_config = options.delete(:wh_config) or fail ":wh_config is required when :psc is specified"
      @psc_sync = PscSync.new(psc, import_config)
    end
  end

  def csv
    @csv ||= Rails.application.csv_impl.read(@eroc_io, :headers => true, :header_converters => :symbol)
  end

  ##
  # @return [Array<String>] error
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

    if @psc_sync
      @psc_sync.sync!
    end

    @errors.empty?
  end

  def errors
    @errors.collect(&:to_s)
  end

  def import_row(row, i)
    if participant = find_participant_or_add_error(row[:participant_id], i)
      update_hilo_if_necessary(participant, row, i)

      register_for_psc_sync(:participant, participant)

      person = get_person_record(row)

      relationship = extract_coded_value(ParticipantPersonLink, :relationship, row, i)
      should_create_ppl = person.new_record? && relationship
      person.save!

      ParticipantPersonLink.create!(:person => person, :participant => participant, :relationship_code => relationship) if should_create_ppl

      event = get_event_record(row, participant, i)
      save_or_report_problems(event, i)
      register_for_psc_sync(:event, event)

      if !@last_event || event.id != @last_event.id
        # n.b.: implicit assumption is that events are in order
        participant.set_state_for_imported_event(event)
        @last_event = event
      end

      contact = get_contact_record(row, event, person, i)
      save_or_report_problems(contact, i)

      if contact.valid? && event.valid? # reduce double reporting
        contact_link = get_contact_link_record(row, event, person, contact)
        save_or_report_problems(contact_link, i)
        register_for_psc_sync(:contact_link, contact_link)
      end
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

  def find_participant_or_add_error(p_id, row_index)
    participant = Participant.where(:p_id => p_id).first
    unless participant
      add_error(row_index, "Unknown participant #{p_id.inspect}.")
      return nil
    end

    # Child
    if participant.p_type_code == 6
      add_error(row_index, "Cannot record a contact for a child participant (#{p_id.inspect}).")
      return nil;
    end

    participant
  end
  private :find_participant_or_add_error

  def update_hilo_if_necessary(participant, row, row_index)
    new_hilo_text = row[:hilo_change]
    new_is_high =
      case new_hilo_text
      when nil
        return
      when /lo/i
        false
      when /hi/i
        true
      else
        add_error(row_index, "Unhandled value for hilo_change: #{new_hilo_text.inspect}.")
        return
      end

    # only update if changed -- switch_arm does not allow you to specify a target arm exc. for hi
    if new_is_high ^ participant.high_intensity
      participant.switch_arm
    elsif new_is_high
      add_error(row_index, "Hilo change to hi but already hi.")
    else
      add_error(row_index, "Hilo change to lo but already lo.")
    end
  end

  def register_for_psc_sync(type, instance)
    return unless @psc_sync

    @psc_sync.send("seen_#{type}", instance)
  end

  def extract_coded_value(model, coded_attribute, row, row_index)
    if row[coded_attribute]
      value = row[coded_attribute] =~ /^[-\d]+/ ? row[coded_attribute].to_i : row[coded_attribute]
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
    event_type = extract_coded_value(Event, :event_type, row, row_index)
    start_date = determine_event_start_date(row, event_type, @last_event, row_index)

    event = find_or_create_event(participant, event_type, start_date)

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

  def determine_event_start_date(row, row_event_type, last_event, row_index)
    not_same_as_last_event_reason =
      if !last_event
        'first row'
      elsif last_event.event_type_code != row_event_type
        "event type #{last_event.event_type_code} -> #{row_event_type}"
      elsif last_event.participant.p_id != row[:participant_id]
        "participant #{last_event.participant.p_id} -> #{row[:participant_id]}"
      end
    same_as_last_event = !not_same_as_last_event_reason

    if row[:event_start_date]
      Date.parse(row[:event_start_date])
    elsif same_as_last_event
      last_event.event_start_date
    else
      add_error(row_index, "Contact for new event (#{not_same_as_last_event_reason}) but no event start date.")
      Date.parse(row[:contact_date])
    end
  end
  private :determine_event_start_date

  def find_or_create_event(participant, event_type, start_date)
    existing_event_criteria = {
      :participant_id => participant.id, :event_type_code => event_type
    }
    unless Event.participant_one_time_only_event_type_codes.include?(event_type)
      existing_event_criteria[:event_start_date] = start_date
    end

    existing_event = Event.where(existing_event_criteria).first

    if existing_event
      existing_event
    else
      Event.create!(existing_event_criteria.merge(:event_start_date => start_date))
    end
  end
  private :find_or_create_event

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

  class PscSync
    attr_reader :participants, :events, :contact_links,
                :psc, :wh_config

    def initialize(psc, wh_config)
      @psc = psc
      @wh_config = wh_config

      # These are maps keyed by public ID for two reasons:
      # * Deduplication. Some records will be referenced from more than one row.
      # * Last state capture. The object cached here will be copied by value
      #   for the PSC sync. We want to capture the latest (i.e. "current") state
      #   for the object.
      @participants = {}
      @events = {}
      @contact_links = {}
    end

    def keygen
      @keygen ||= lambda do |*c|
        ['eroc', c].flatten.join(':')
      end
    end

    def seen_participant(participant)
      participants[participant.public_id] = participant
    end

    def seen_event(event)
      events[event.public_id] = event
    end

    def seen_contact_link(contact_link)
      contact_links[contact_link.public_id] = contact_link
    end

    def sync!
      wh_config.shell.say_line("Preparing records for PSC sync...")

      # Wipe previously loaded values
      Rails.application.redis.tap do |r|
        keys = r.keys(keygen['*'])
        r.del(*keys) unless keys.empty?
      end

      sync_loader = Psc::SyncLoader.new(keygen)

      participants.values.each do |p|
        sync_loader.cache_participant(p)
      end

      events.values.each do |e|
        sync_loader.cache_event(e, e.participant)
      end

      contact_links.values.each do |cl|
        sync_loader.cache_contact_link(cl, cl.contact, cl.event, cl.participant)
      end

      NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(@psc, @wh_config, keygen).import
    end
  end
end
