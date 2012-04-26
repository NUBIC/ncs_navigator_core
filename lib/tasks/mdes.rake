namespace :mdes do
  namespace :code_lists do
    task :base => :environment do
      require 'ncs_navigator/core/mdes_code_list_loader'
    end

    desc 'Generate the code list YAML file'
    task :yaml => :base do
      NcsNavigator::Core::MdesCodeListLoader.new(:interactive => true).create_yaml
      $stderr.puts "Code list YAML regenerated. Please verify and commit it."
    end

    desc 'Load the code lists into the ncs_codes table'
    task :load => :base do
      $stderr.puts "Tip: you can load all the seed data with db:seed."

      require 'benchmark'
      $stderr.puts(Benchmark.measure do
        NcsNavigator::Core::MdesCodeListLoader.new(:interactive => true).load_from_yaml
      end)
    end

    desc 'Counts the number of code list entries'
    task :count => :base do
      $stderr.puts "There are #{NcsCode.count} codes."
    end
  end
end
