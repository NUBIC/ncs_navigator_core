namespace :mdes do
  
  desc 'loads 2.0 MDES codes from xsd'
  task :load_codes_from_schema => :environment do
    require 'mdes_data_loader'
    MdesDataLoader::load_codes_from_schema('2.0')
  end
  
  desc 'loads 1. MDES codes from xsd'
  task :load_codes_from_schema_12 => :environment do
    require 'mdes_data_loader'
    MdesDataLoader::load_codes_from_schema('1.2')
  end
  
  desc 'loads 2.0 MDES codes from xsd'
  task :load_codes_from_schema_20 => :environment do
    require 'mdes_data_loader'
    MdesDataLoader::load_codes_from_schema('2.0')
  end

  desc 'outputs the count of ncs data elements'
  task :count_codes => :environment do 
    puts "There are #{NcsCode.count} codes"
  end

end
