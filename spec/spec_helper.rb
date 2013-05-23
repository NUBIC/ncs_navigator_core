# -*- coding: utf-8 -*-

require 'simplecov'
SimpleCov.start 'rails'

require 'rubygems'
require 'spork'
require 'database_cleaner'

require File.expand_path('../active_record_query_profiler', __FILE__)

# I would prefer to put this just in the affected spec(s), but that's too late.
# Workaround for https://github.com/NUBIC/surveyor/issues/381
require 'fastercsv' # Counterintuitive!

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

  # There are initializers that depend on this being set.
  require File.expand_path('../support/suite_configuration', __FILE__)
  NcsNavigator::Core::Spec.reset_navigator_ini

  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'

  # Factory Girl was not autoloading factories hence the call to Factory.find_definitions
  # cf. http://stackoverflow.com/questions/1160004/setup-factory-girl-with-testunit-and-shoulda
  require 'factory_girl'
  FactoryGirl.find_definitions

  require 'shoulda'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  NcsNavigatorCore.mdes_version = '3.1' # TODO: support with different versions

  module TestLogins
    def user_login
      Aker.authority.valid_credentials?(:user, 'test_user', 'test_user')
    end

    def admin_login
      Aker.authority.valid_credentials?(:user, 'admin_user', 'admin_user')
    end

    def login(as)
      controller.request.env['aker.check'] = Aker::Rack::Facade.new(Aker.configuration, as)
    end

    def capybara_login(as)
      current_user = Aker::User.new(as, "NCSNavigator")
      visit '/login'
      fill_in 'username', :with => as
      fill_in 'password', :with => as
      click_button 'Log in'
      current_user
    end
  end

  module Pers
    class Base
      def ensure_bcauditable
        true
      end
    end
  end

  LOOKUP_TABLES = %w(ncs_codes event_type_order)

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

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
      NcsNavigator::Core::Mdes::CodeListLoader.new.load_from_pg_dump

      # The truncation wipes out the persisted event type order, so we restore
      # it here.
      EventTypeOrder.persist
    end

    config.before(:each, :clean_with_truncation) do
      DatabaseCleaner.strategy = [:truncation, { :except => LOOKUP_TABLES }]
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

    config.after(:all, :shared_test_data) do
      DatabaseCleaner.clean_with(:truncation, :except => LOOKUP_TABLES)
    end

    config.include ScheduledActivities
    config.include TestLogins
    [
      TestSurveys,
      ParticipantVerification,
      PregnancyScreener,
      PbsEligibilityScreener,
      Tracing,
      LoIntensityQuex,
      PpgFollowUp,
      PrePregnancyVisit,
      PregnancyVisitOne,
      PregnancyVisitTwo,
      BirthVisit,
      SamplesAndSpecimens,
      PostNatal,
      NonInterview,
      ChildAndAdHoc,
      PbsParticipantVerification
    ].each { |test_survey| config.include test_survey }

    require 'support/matchers'
    config.include NcsNavigator::Core::Spec::Matchers

    if ENV['PROFILE_DB']
      ActiveRecordQueryProfiler.register(config)
    end
  end

  def load_survey_string(s)
    Surveyor::Parser.new.parse(s)
  end

  def load_survey_questions_string(questions_dsl)
    load_survey_string <<-SURVEY
      survey "Test Survey", :description => 'Tester', :instrument_version => '1.8', :instrument_type => 3 do
        section "A" do
          #{questions_dsl}
        end
      end
    SURVEY
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
    NcsNavigator::Warehouse::Configuration.new.
      tap { |c| c.mdes_version = NcsNavigatorCore.mdes_version.number }.models_module
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
      @user = mock(:username => "dude", :cas_proxy_ticket => "PT-cas-ticket")

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
