require 'rubygems'
require 'spork'
require 'database_cleaner'

require 'ncs_navigator/configuration'

require 'spec/active_record_query_profiler'

# --- Instructions ---
# Sort the contents of this file into a Spork.prefork and a Spork.each_run
# block.
#
# The Spork.prefork block is run only once when the spork server is started.
# You typically want to place most of your (slow) initializer code in here, in
# particular, require'ing any 3rd-party gems that you don't normally modify
# during development.
#
# The Spork.each_run block is run each time you run your specs.  In case you
# need to load files that tend to change during development, require them here.
# With Rails, your application modules are loaded automatically, so sometimes
# this block can remain empty.
#
# Note: You can modify files loaded *from* the Spork.each_run block without
# restarting the spork server.  However, this file itself will not be reloaded,
# so if you change any of the code inside the each_run block, you still need to
# restart the server.  In general, if you have non-trivial code in this file,
# it's advisable to move it into a separate file so you can easily edit it
# without restarting spork.  (For example, with RSpec, you could move
# non-trivial code into a file spec/support/my_helper.rb, making sure that the
# spec/support/* files are require'd from inside the each_run block.)
#
# Any code that is left outside the two blocks will be run during preforking
# *and* during each_run -- that's probably not what you want.
#
# These instructions should self-destruct in 10 seconds.  If they don't, feel
# free to delete them.

# This file is copied to spec/ when you run 'rails generate rspec:install'
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Factory Girl was not autoloading factories hence the call to Factory.find_definitions
  # cf. http://stackoverflow.com/questions/1160004/setup-factory-girl-with-testunit-and-shoulda
  require 'factory_girl'
  FactoryGirl.find_definitions

  require 'shoulda'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  NcsNavigator.configuration =
    NcsNavigator::Configuration.new(File.expand_path('../navigator.ini', __FILE__))

  module TestLogins
    def user_login
      Aker.authority.valid_credentials?(:user, 'test_user', 'test_user')
    end

    def login(as)
      controller.request.env['aker.check'] = Aker::Rack::Facade.new(Aker.configuration, as)
    end
  end

  module Pers
    class Base
      def ensure_bcauditable
        true
      end
    end
  end

  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true

    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    # Using DatabaseCleaner instead
    # config.use_transactional_fixtures = true

    config.before(:all) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each, :clean_with_truncation) do
      DatabaseCleaner.strategy = :truncation
    end

    config.after(:each, :clean_with_truncation) do
      DatabaseCleaner.strategy = :transaction
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.extend VCR::RSpec::Macros

    config.include TestLogins
    config.include TestSurveys

    if ENV['PROFILE_DB']
      ActiveRecordQueryProfiler.register(config)
    end
  end

  def create_missing_in_error_ncs_codes(cls)
    cls.reflect_on_all_associations.each do |association|
      if association.options[:class_name] == "NcsCode"
        list_name = association.options[:conditions].gsub("'", "").gsub("list_name = ", "")
        Factory(:ncs_code, :local_code => '-4', :display_text => 'Missing in Error', :list_name => list_name)
      end
    end
  end

  def create_all_event_types

    [
      [7,	"Pregnancy Probability"],
      [9,	"Pregnancy Screening - Household Enumeration Group"],
      [10,	"Informed Consent"],
      [11,	"Pre-Pregnancy Visit"],
      [13,	"Pregnancy Visit 1"],
      [15,	"Pregnancy Visit 2"],
      [18,	"Birth"],
      [19,	"Father"],
      [21,	"Validation"],
      [23,	"3 Month"],
      [24,	"6 Month"],
      [26,	"9 Month"],
      [27,	"12 Month"],
      [29,	"Pregnancy Screener"],
      [30,	"18 Month"],
      [31,	"24 Month"],
      [32,	"Low to High Conversion"],
      [33,	"Low Intensity Data Collection"],
      [-5,	"Other"]
    ].each do |lc, txt|
      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => txt, :local_code => lc)
    end

  end

  def load_survey_string(s)
    Surveyor::Parser.new.parse(s)
  end

  def with_versioning
    was_enabled = PaperTrail.enabled?
    PaperTrail.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
    end
  end

  ::ActiveSupport::Deprecation.silenced = true

  # Preload slow warehouse infrastructure only when actually using spork
  if Spork.using_spork?
    puts 'Preloading warehouse models & MDES tables (spork only)'
    require 'ncs_navigator/warehouse'
    require 'ncs_navigator/warehouse/models/two_point_zero'
    NcsNavigatorCore.mdes.transmission_tables
  end

  def setup_schedule_and_create_child_placeholder

    let(:scheduled_study_segment_identifier) { "f699ac2e-9784-48b7-bfc6-229e54d233b7" }
    let(:person) {Factory(:person, :first_name => "Francesca", :last_name => "Zupicich", :person_dob => '1980-02-14',
                          :person_id => "placeholder_child_participant")}
    let(:participant) { Factory(:participant, :p_id => "placeholder_child_participant") }
    let(:xml) { %Q(<?xml version="1.0" encoding="UTF-8"?><scheduled-study-segment id="a5fd83f9-e2ca-4481-8ce3-70406dfbcddc"></scheduled-study-segment>) }
    let(:response_body) { Nokogiri::XML(xml) }

    before(:each) do
      create_missing_in_error_ncs_codes(Event)
      Factory(:ncs_code, :list_name => "PERSON_PARTCPNT_RELTNSHP_CL1", :display_text => "Self", :local_code => 1)

      @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")

      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "Birth", :local_code => 18)
      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "3 Month", :local_code => 23)
      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "6 Month", :local_code => 24)
      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "9 Month", :local_code => 26)
      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "12 Month", :local_code => 27)
      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "18 Month", :local_code => 30)
      Factory(:ncs_code, :list_name => 'EVENT_TYPE_CL1', :display_text => "24 Month", :local_code => 31)

      participant.person = person
      participant.save!
    end

    let(:psc) { PatientStudyCalendar.new(@user) }

  end

end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end
