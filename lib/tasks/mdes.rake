namespace :mdes do
  desc 'Initialize the code lookup values.'
  task :load_codes_from_schema => :environment do
    require 'mdes_data_loader'
    MdesDataLoader::load_codes_from_schema
  end

  desc 'outputs the count of ncs data elements'
  task :count_codes => :environment do
    puts "There are #{NcsCode.count} codes."
  end
end
