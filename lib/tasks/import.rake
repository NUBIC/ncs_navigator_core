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

  task :find_participants_for_psc => :environment do |t|
    class << t; attr_accessor :participants; end

    # Expected participants for PSC are those 1) actively followed and 2) not children.
    t.participants = Participant.includes(:participant_person_links => [:person], :events => [:event_type]).
      where('being_followed = ? AND p_type_code != ?', true, 6)
  end

  task :set_whodunnit => :environment do
    PaperTrail.whodunnit = 'import rake tasks'
  end

  def import_wh_config
    task('import:warehouse_setup').config
  end

  def user_for_psc
    task('import:psc_setup').user
  end

  def psc
    PatientStudyCalendar.new(user_for_psc, NcsNavigatorCore.psc_logger)
  end

  def expected_participants_for_psc
    task('import:find_participants_for_psc').participants
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

    importer = NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(psc, import_wh_config)
    importer.import
  end

  desc 'Reset the PSC sync caches so that the PSC sync can be retried. (You should wipe the subject info in PSC also.)'
  task 'operational_psc:reset' => [:psc_setup, :warehouse_setup, :environment] do
    require 'ncs_navigator/core'

    importer = NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(psc, import_wh_config)
    importer.reset
  end

  desc 'Check for imported participants which are not in PSC'
  task 'operational_psc:check' => [:psc_setup, :warehouse_setup, :environment, :find_participants_for_psc] do
    require 'ncs_navigator/core'

    missing_ps = expected_participants_for_psc.reject { |p|
      psc.is_registered?(p).tap do |result|
        $stderr.write(result ? '.' : '!')
        $stderr.flush
      end
    }
    $stderr.puts

    if missing_ps.empty?
      $stderr.puts "All #{expected_participants_for_psc.size} expected participant#{'s' unless expected_participants_for_psc.size == 1} present."
    else
      $stderr.puts "The following participant#{'s' unless missing_ps.size == 1} expected but not present:"
      missing_ps.each do |p|
        $stderr.puts "* #{p.public_id} (cases: #{p.id})"
      end
    end
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

  desc 'Schedule upcoming events for followed participants if needed'
  task :schedule_participant_events => [:psc_setup, :environment, :set_whodunnit, :find_participants_for_psc]  do
    ps_to_advance = expected_participants_for_psc.select { |p| p.pending_events.empty? }

    $stderr.puts "#{ps_to_advance.size} of #{expected_participants_for_psc.size} followed participants need pending events."

    ps_to_advance.each_with_index do |p, i|
      $stderr.print("\rAdvancing #{i + 1}/#{ps_to_advance.size} to next state...")
      Rails.logger.info("Advancing imported case #{p.p_id} to next state")

      last_event = Event.sort(p.events).reverse.sort_by { |e| e.event_start_date }.last

      Rails.logger.info("- Currently #{p.state.inspect}")
      Rails.logger.info("- Updating based on #{last_event.event_type} on #{last_event.event_start_date}")
      p.update_state_to_next_event(last_event)
      Rails.logger.info("- Updated to #{p.state.inspect}")

      Rails.logger.info("- Scheduling in PSC...")
      Event.schedule_and_create_placeholder(psc, p)
      p.events.reload # for next log statement
      Rails.logger.info("- PSC scheduling completed. Pending events are now #{p.pending_events.collect { |e| e.event_type.to_s }.inspect}")
      if p.pending_events.empty?
        $stderr.puts("\n#{p.p_id} still has no pending events! Its last event was #{last_event.event_type} (#{last_event.event_type.local_code}) on #{last_event.event_start_date} (#{last_event.event_id}). Its current state is #{p.state.inspect}.")
      end
    end
    $stderr.puts("\rAdvanced #{ps_to_advance.size} case(s) to next state.")
  end

  desc 'Re-schedule events that are pending (i.e. w/out an event_end_date)'
  task :reschedule_pending_events => [:psc_setup, :environment] do
    date = 4.days.from_now.to_date

    events = Event.where("participant_id is not null and event_end_date is null and event_type_code <> 29").all

    events.each do |event|
      reason = "Import task: Rescheduling pending event [#{event.event_id}] #{event.event_type} to #{date}."
      psc.schedule_pending_event(event, Psc::ScheduledActivity::SCHEDULED, date, reason)
    end
  end

  desc 'Import an EROC'
  task :eroc, [:eroc_csv] => [:psc_setup, :warehouse_setup, :environment, :set_whodunnit] do |t, args|
    fail 'Please specify the path to the EROC csv' unless args[:eroc_csv]

    require 'ncs_navigator/core'

    options = {}
    unless ENV['NO_PSC']
      options[:psc] = psc
      options[:wh_config] = import_wh_config
    end

    importer = NcsNavigator::Core::RecordOfContactImporter.new(
      File.open(args[:eroc_csv]),
      options
    )

    unless importer.import_data
      fail importer.errors.join("\n")
    end
  end
end
