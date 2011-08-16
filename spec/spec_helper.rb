# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Factory Girl was not autoloading factories hence the call to Factory.find_definitions
# cf. http://stackoverflow.com/questions/1160004/setup-factory-girl-with-testunit-and-shoulda
require 'factory_girl'
Factory.find_definitions

require 'shoulda'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

module TestLogins
  def user_login
    person = Factory(:person, :username => 'pfr957')
    Aker.authority.valid_credentials?(:user, person.username, person.username)
  end

  def admin_login
    person = Factory(:person, :username => 'pfr957')
    Aker.authority.valid_credentials?(:user, person.username, person.username)
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
  config.use_transactional_fixtures = true
  
  config.include TestLogins
end

def create_missing_in_error_ncs_codes(cls)
  cls.reflect_on_all_associations.each do |association|
    if association.options[:class_name] == "NcsCode"
      list_name = association.options[:conditions].gsub("'", "").gsub("list_name = ", "")
      Factory(:ncs_code, :local_code => '-4', :display_text => 'Missing in Error', :list_name => list_name)
    end
  end
end
