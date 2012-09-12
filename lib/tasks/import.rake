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

    aker_cas_cli_options = {}
    if ENV['DEV_ENV']
      aker_cas_cli_options = { :verify_mode => OpenSSL::SSL::VERIFY_NONE }
    end

    cas_cli = Aker::CasCli.new(Aker.configuration, aker_cas_cli_options)

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
  task :all => [
    :psc_setup,
    :operational, :operational_psc, :unused_operational,
    :instruments
  ]

  desc 'Import operational data'
  task :operational => [:warehouse_setup, :environment] do
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

    importer.import(*tables)
  end

  desc 'Synchronize PSC to the data imported by import:operational'
  task :operational_psc => [:psc_setup, :warehouse_setup, :environment] do
    require 'ncs_navigator/core'
    psc = PatientStudyCalendar.new(user_for_psc)

    importer = NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(psc, import_wh_config)
    importer.import
  end

  desc 'Reset the PSC sync caches so that the PSC sync can be retried. (You should wipe the subject info in PSC also.)'
  task 'operational_psc:reset' => [:psc_setup, :warehouse_setup, :environment] do
    require 'ncs_navigator/core'
    psc = PatientStudyCalendar.new(user_for_psc)

    importer = NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(psc, import_wh_config)
    importer.reset
  end

  desc 'Import instrument data'
  task :instruments => [:warehouse_setup, :environment] do
    require 'ncs_navigator/core'

    importer = NcsNavigator::Core::Warehouse::LegacyInstrumentImporter.new(import_wh_config)
    importer.import
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
      Event.schedule_and_create_placeholder(psc, p)
    end
  end

  desc 'Re-schedule events that are pending (i.e. w/out an event_end_date)'
  task :reschedule_pending_events => [:psc_setup, :environment] do
    date = 4.days.from_now.to_date

    events = Event.where("participant_id is not null and event_end_date is null and event_type_code <> 29").all
    psc = PatientStudyCalendar.new(user_for_psc)

    events.each do |event|
      reason = "Import task: Rescheduling pending event [#{event.event_id}] #{event.event_type} to #{date}."
      psc.schedule_pending_event(event, Psc::ScheduledActivity::SCHEDULED, date, reason)
    end
  end
end
