namespace :import do
  task :warehouse_setup do |t|
    class << t; attr_accessor :config; end

    source_warehouse_config_file = ENV['IMPORT_CONFIG'] || '/etc/nubic/ncs/warehouse/import.rb'

    require 'ncs_navigator/warehouse'

    t.config = NcsNavigator::Warehouse::Configuration.
      from_file(source_warehouse_config_file)

    NcsNavigator::Warehouse::DatabaseInitializer.new(t.config).set_up_repository
  end

  def import_wh_config
    task('import:warehouse_setup').config
  end

  desc 'Import all data'
  task :all => [:operational, :instruments, :unused_instruments]

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
end
