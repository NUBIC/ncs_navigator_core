abort 'This script must be run in test' unless Rails.env.test?

require 'celluloid'
require 'database_cleaner'
require 'irb'
require 'logger'
require 'ncs_navigator/core/mdes_code_list_loader'
require 'surveyor/parser'

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

LOG = Logger.new($stderr)

class SurveyLoader
  include Celluloid

  def load_survey(fn)
    LOG.info "Loading survey: #{File.basename(fn)}"
    Surveyor::Parser.new.parse(File.read(fn))
  end
end

s = SurveyLoader.pool(:size => 4)

# Loading data just makes a mess in the log, so turn logging off for that bit
Rails.logger.silence do
  LOG.info 'Cleaning database'
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean

  LOG.info 'Loading code lists'
  NcsNavigatorCore.mdes_version = '3.1'
  NcsNavigator::Core::MdesCodeListLoader.new.load_from_yaml

  surveys = Dir["#{Rails.root}/{internal_surveys,surveys}/**/*.rb"]
  surveys.map { |fn| s.future(:load_survey, fn) }.all?(&:value)
end

puts <<-END
Use fw(json) to load a fieldwork set from a JSON object.
Use m(json, fw) to create a merge object.
To run a merge, create a merge object and invoke #run on it.

All changes to the database will be erased when you exit.
END

IRB.start
