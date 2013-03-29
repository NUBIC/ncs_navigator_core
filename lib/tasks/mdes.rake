namespace :mdes do
  namespace :code_lists do
    task :base => :environment do
      require 'ncs_navigator/core/mdes/code_list_loader'
    end

    desc 'Generate the code list YAML file for the current MDES version'
    task :yaml => :base do
      NcsNavigator::Core::Mdes::CodeListLoader.new(:interactive => true).create_yaml
      $stderr.puts "Code list YAML regenerated. Please verify and commit it."
    end

    desc 'Generate the code list pg_dump file for the current MDES version'
    task :pg_dump => :load_from_yaml do
      NcsNavigator::Core::Mdes::CodeListLoader.new(:interactive => true).create_pg_dump
      $stderr.puts "Code list pg_dump regenerated. Please verify and commit it."
    end

    # n.b.: this touches your development database
    desc 'Generate the code list YAML and pg_dump files for every supported MDES version'
    task :all => :base do
      versions = NcsNavigator::Core::Mdes::SUPPORTED_VERSIONS.dup

      # move current version to end so that it is the one left in the database.
      current_version = NcsNavigator::Core::Mdes::Version.new.number
      versions.delete(current_version)
      versions << current_version

      versions.each do |mdes_version|
        $stderr.puts "Creating for #{mdes_version}..."; $stderr.flush
        loader = NcsNavigator::Core::Mdes::CodeListLoader.new(:interactive => true, :mdes_version => mdes_version)
        loader.create_yaml
        loader.load_from_yaml
        loader.create_pg_dump
        $stderr.puts "#{mdes_version} done."
      end
      $stderr.puts "All code list YAML & pg_dumps regenerated. Please verify and commit."
      $stderr.puts "All the pgcustom files will show as dirty;\n you should only commit those where the corresponding YAML file changed also."
    end

    desc 'Load the code lists for the current MDES version into the ncs_codes table using the YAML'
    task :load_from_yaml => :base do
      require 'benchmark'
      $stderr.puts(Benchmark.measure do
        NcsNavigator::Core::Mdes::CodeListLoader.new(:interactive => true).load_from_yaml
      end)
    end

    desc 'Load the code lists for the current MDES version into the ncs_codes table using the pgcustom file'
    task :load_from_pg_dump => :base do
      require 'benchmark'
      $stderr.puts(Benchmark.measure do
        NcsNavigator::Core::Mdes::CodeListLoader.new(:interactive => true).load_from_pg_dump
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
