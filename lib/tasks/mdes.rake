require 'csv'

namespace :mdes do
  
  # MDES Version 2.0
  LOAD_FILE = 'mdes_code_lists_v2.0.csv'

  desc 'loads MDES codes into the NcsCodes table'
  task :load_codes => :environment do
    require 'mdes_data_loader_2'
    MdesDataLoader2::load_codes(LOAD_FILE)
  end

  desc 'outputs the count of ncs data elements'
  task :count_codes => :environment do 
    puts "There are #{NcsCode.count} codes"
  end

end
