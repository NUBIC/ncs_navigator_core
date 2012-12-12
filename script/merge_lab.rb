abort 'This script must be run in test' unless Rails.env.test?

require 'irb'
require 'database_cleaner'
require 'ncs_navigator/core/mdes_code_list_loader'

def fw(json)
  Fieldwork.new.tap do |fw|
    fw.client_id = 'test'
    fw.end_date = Date.today + 1
    fw.start_date = Date.today
    fw.generated_for = 'test'
    fw.staff_id = 'test'
    fw.original_data = json

    fw.save!
  end
end

def m(json, fw)
  fw.merges.create!(:proposed_data => json,
                    :client_id => 'test',
                    :staff_id => 'test',
                    :username => 'test')
end

puts 'Cleaning database'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

puts 'Loading code lists'
NcsNavigatorCore.mdes_version = '3.1'
NcsNavigator::Core::MdesCodeListLoader.new.load_from_yaml

puts 'Loading surveys'
# TODO

puts <<-END
Use fw(json) to load a fieldwork set from a JSON object.
Use m(json, fw) to create a merge object.
To run a merge, create a merge object and invoke #run on it.

All changes to the database will be erased when you exit.
END

IRB.start
