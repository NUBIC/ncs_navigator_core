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

  task :psc_setup do |t|
    require 'highline'
    class << t; attr_accessor :psc_username_password; end

    hl = HighLine.new
    username = hl.ask("Username for PSC: ")
    password = hl.ask("Password for PSC: ") { |q| q.echo = '*' }
    t.psc_username_password = [username, password].join(',')
  end

  def import_wh_config
    task('import:warehouse_setup').config
  end

  desc 'Import all data'
  task :all => [:psc_setup, :operational, :unused_operational, :instruments, :unused_instruments]

  desc 'Import operational data'
  task :operational => [:psc_setup, :warehouse_setup, :environment] do
    require 'ncs_navigator/core'
    importer = NcsNavigator::Core::Warehouse::OperationalImporter.new(import_wh_config)

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

    begin
      ENV['PSC_USERNAME_PASSWORD'] = task('import:psc_setup').psc_username_password
      importer.import(*tables)
    ensure
      ENV['PSC_USERNAME_PASSWORD'] = nil
    end
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
  task :schedule_participant_events => [:psc_setup, :warehouse_setup, :environment]  do
    begin
      ENV['PSC_USERNAME_PASSWORD'] = task('import:psc_setup').psc_username_password
      days_out = ENV['DAYS_OUT'] || 14

      participants = Participant.select { |p| p.pending_events.blank? && !p.events.blank? }.
        select { |p| p.person }

      psc = PatientStudyCalendar.new(nil)

      participants.each do |p|
        psc.schedule_next_segment(p)
      end
    ensure
      ENV['PSC_USERNAME_PASSWORD'] = nil
    end
  end

  desc 'Re-schedule events that are pending (i.e. w/out an event_end_date)'
  task :reschedule_pending_events => [:psc_setup, :warehouse_setup, :environment] do
    begin
      ENV['PSC_USERNAME_PASSWORD'] = task('import:psc_setup').psc_username_password
      date = 4.days.from_now.to_date

      events = Event.where("event_end_date is null and event_type_code <> 29").all
      psc = PatientStudyCalendar.new(nil)

      events.each do |event|
        reason = "Import task: Rescheduling pending event [#{event.id}] #{event.event_type} to #{date}."
        psc.schedule_pending_event(event.participant, event.event_type.to_s, PatientStudyCalendar::ACTIVITY_SCHEDULED, date, reason)
      end
    ensure
      ENV['PSC_USERNAME_PASSWORD'] = nil
    end
  end

  desc 'After an import, set an end date and final disposition for all pregnancy screener events'
  task :close_pregnancy_screener_events => [:psc_setup, :warehouse_setup, :environment] do

    begin
      ENV['PSC_USERNAME_PASSWORD'] = task('import:psc_setup').psc_username_password

      events = Event.where("event_end_date is null and event_type_code = 29").all
      psc = PatientStudyCalendar.new(nil)
      disposition_category = NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 2)

      events.each do |event|
        end_date = event.event_start_date.blank? ? Date.today : event.event_start_date
        event.event_disposition = 535 # Out of Window
        event.event_end_date = end_date
        event.event_disposition_category = disposition_category
        event.save!

        # TODO: create something in psc that closes pregnancy screener events since this might schedule something new
        reason = "Import task: Closing pregnancy screener event [#{event.id}]."
        psc.schedule_pending_event(event.participant, event.event_type.to_s, PatientStudyCalendar::ACTIVITY_CANCELED, Date.today, reason)
      end
    ensure
      ENV['PSC_USERNAME_PASSWORD'] = nil
    end

  end

end
