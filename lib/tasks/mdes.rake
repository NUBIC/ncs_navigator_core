namespace :mdes do
  namespace :code_lists do
    task :base => :environment do
      require 'ncs_navigator/core/mdes_code_list_loader'
    end

    desc 'Generate the code list YAML file for the current MDES version'
    task :yaml => :base do
      NcsNavigator::Core::MdesCodeListLoader.new(:interactive => true).create_yaml
      $stderr.puts "Code list YAML regenerated. Please verify and commit it."
    end

    desc 'Generate the code list YAML file for the all supported MDES versions'
    task :all_yaml => :base do
      %w(2.0 2.1 2.2 3.0 3.1).each do |mdes_version|
        $stderr.print "Creating for #{mdes_version}..."; $stderr.flush
        NcsNavigator::Core::MdesCodeListLoader.new(:interactive => true, :mdes_version => mdes_version).create_yaml
        $stderr.puts 'done.'
      end
      $stderr.puts "All code list YAML regenerated. Please verify and commit them."
    end

    desc 'Load the code lists for the current MDES version into the ncs_codes table'
    task :load => :base do
      $stderr.puts "Tip: you can load all the seed data with db:seed."

      require 'benchmark'
      $stderr.puts(Benchmark.measure do
        NcsNavigator::Core::MdesCodeListLoader.new(:interactive => true).load_from_yaml
      end)
    end

    desc 'Counts the number of code list entries currently loaded'
    task :count => :base do
      $stderr.puts "There are #{NcsCode.count} codes."
    end
  end

  namespace :version do
    task :base => :environment do
      require 'ncs_navigator/core/mdes/version'
    end

    desc 'Print the current MDES version'
    task :show => :base do
      puts "Current MDES version is #{NcsNavigatorCore.mdes.version}."
    end

    desc 'Set the MDES version in a new deployment'
    task :set, [:version] => [:base] do |t, args|
      NcsNavigator::Core::Mdes::Version.set!(args[:version])
    end

    desc 'Convert this instance to the named MDES version'
    task :migrate, [:to_version] => [:environment] do |t, args|
      fail "Please specify :to_version" unless args[:to_version]
      NcsNavigator::Core::Mdes::VersionMigrator.
        new(:interactive => true).migrate!(args[:to_version])
    end
  end
end
