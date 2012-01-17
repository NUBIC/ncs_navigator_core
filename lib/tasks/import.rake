namespace :import do
  task :warehouse_setup do |t|
    class << t; attr_accessor :config; end

    source_warehouse_config_file = ENV['IMPORT_CONFIG'] || '/etc/nubic/ncs/warehouse/import.rb'

    require 'ncs_navigator/warehouse'

    t.config = NcsNavigator::Warehouse::Configuration.
      from_file(source_warehouse_config_file)
    t.config.set_up_logs

    NcsNavigator::Warehouse::DatabaseInitializer.new(t.config).set_up_repository
  end

  task :psc_setup => :environment do |t|
    require 'highline'
    require 'aker/cas_cli'
    class << t; attr_accessor :user; end

    cas_cli = Aker::CasCli.new(Aker.configuration)

    hl = HighLine.new
    username = hl.ask("Username for PSC: ")
    password = hl.ask("Password for PSC: ") { |q| q.echo = '*' }

    t.user = cas_cli.authenticate(username, password)
  end

  def import_wh_config
    task('import:warehouse_setup').config
  end

  def user_for_psc
    task('import:psc_setup').user
  end

  desc 'Import all data'
  task :all => [:psc_setup, :operational, :unused_operational, :instruments, :unused_instruments]

  desc 'Import operational data'
  task :operational => [:psc_setup, :warehouse_setup, :environment] do
    require 'ncs_navigator/core'
    importer = NcsNavigator::Core::Warehouse::OperationalImporter.new(
      import_wh_config, user_for_psc)

    tables = case
             when ENV['TABLES']
               ENV['TABLES'].split(',').collect(&:to_sym)
             when ENV['START_WITH']
               start = ENV['START_WITH'].to_sym
               all_tables = importer.automatic_producers.collect(&:name)
               start_i = all_tables.index(start)
               unless start_i
                 fail "Can't start from Unknown table #{start}"
               end
               all_tables[start_i .. all_tables.size] + [:events, :link_contacts, :instruments]
             else
               []
             end

    puts "Importing only #{tables.join(', ')}." unless tables.empty?

    importer.import(*tables)
  end

  desc 'Import instrument data'
  task :instruments => [:warehouse_setup, :environment] do
    require 'ncs_navigator/core'

    importer = NcsNavigator::Core::Warehouse::InstrumentImporter.new(import_wh_config)
    importer.import
  end

  desc 'Pass unused instrument data through to an XML file'
  task :unused_instruments => [:warehouse_setup, :environment] do
    require 'ncs_navigator/core'

    pass = NcsNavigator::Core::Warehouse::UnusedInstrumentPassthrough.new(import_wh_config)
    pass.import
  end

  desc 'Pass unused operational data through to an XML file'
  task :unused_operational => [:warehouse_setup, :environment] do
    require 'ncs_navigator/core'

    pass = NcsNavigator::Core::Warehouse::UnusedOperationalPassthrough.new(import_wh_config)
    pass.import
  end

  desc 'Schedules upcoming events for participants'
  task :schedule_participant_events => [:psc_setup, :environment]  do
    days_out = ENV['DAYS_OUT'] || 14

    participants = Participant.select { |p| p.pending_events.blank? && !p.events.blank? }.
      select { |p| p.person }

    psc = PatientStudyCalendar.new(user_for_psc)

    participants.each do |p|
      psc.schedule_next_segment(p)
    end
  end

  desc 'Re-schedule events that are pending (i.e. w/out an event_end_date)'
  task :reschedule_pending_events => [:psc_setup, :environment] do
    date = 4.days.from_now.to_date

    events = Event.where("participant_id is not null and event_end_date is null and event_type_code <> 29").all
    psc = PatientStudyCalendar.new(user_for_psc)

    events.each do |event|
      reason = "Import task: Rescheduling pending event [#{event.event_id}] #{event.event_type} to #{date}."
      psc.schedule_pending_event(event.participant, event.event_type.to_s, PatientStudyCalendar::ACTIVITY_SCHEDULED, date, reason)
    end
  end

  # TODO: this could pull in and close an in-progress (i.e., not
  # abandoned) pregnancy screener.
  desc 'After an import, set an end date and final disposition for all pregnancy screener events'
  task :close_pregnancy_screener_events => [:psc_setup, :environment] do

    events = Event.where("participant_id is not null and event_end_date is null and event_type_code = 29").all
    psc = PatientStudyCalendar.new(user_for_psc)
    disposition_category = NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 2)
    events.each do |event|
      close_enumeration(event, disposition_category)
      # TODO: create something in psc that closes pregnancy screener events since this might schedule something new
      reason = "Import task: Closing pregnancy screener event [#{event.event_id}]."
      psc.schedule_pending_event(event.participant, event.event_type.to_s, PatientStudyCalendar::ACTIVITY_CANCELED, Date.today, reason)
    end
  end

  def close_enumeration(event, disposition_category)
    end_date = event.event_start_date.blank? ? Date.today : event.event_start_date
    event.event_disposition = 535 # Out of Window
    event.event_end_date = end_date
    event.event_disposition_category = disposition_category
    event.save!
  end

end
