source 'http://rubygems.org'

gem 'rails', '3.1.0'

gem 'bcdatabase', '~> 1.0'
gem 'aker', '~> 3.0'
gem 'aker-rails'
gem 'compass'
gem 'fastercsv'
gem 'haml', '~> 3.1'
gem 'pg'
gem 'ruby-debug'
gem 'jquery-rails'

gem 'ncs_mdes', '~> 0.4.0'
gem 'formtastic', '1.2.4'
gem 'surveyor', :git => 'git://github.com/NUBIC/surveyor.git'
gem 'psc'
gem 'ncs_navigator_configuration'

gem 'state_machine'
gem 'state_machine-audit_trail'
gem 'uuid'
gem 'will_paginate'

group :development do
  gem 'capistrano'
  gem 'watchr'
  gem 'rb-fsevent'
  gem 'growl_notify' # or gem 'growl'
end

group :development, :test do
  # Since the transformer isn't run from within the app, don't include
  # its dependencies in production.
  gem 'ncs_mdes_warehouse', '~> 0.0',
    :git => 'git://github.com/NUBIC/ncs_mdes_warehouse.git'
  # gem 'ncs_mdes_warehouse', '~> 0.0', :path => '../ncs_mdes_warehouse'
end

group :development, :test, :ci do
  gem 'rspec-rails', '2.6.1'

  gem 'guard'
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-coffeescript'
  gem 'guard-livereload'
  gem 'guard-bundler'
  gem 'jasmine'

  gem 'newrelic_rpm'
end

group :test, :ci do
  gem 'cucumber'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl'
  gem 'rcov'
  gem 'pickle'
  gem 'vcr'
  gem 'fakeweb'

  gem "spork", "> 0.9.0.rc"
  gem "guard-spork"

  gem 'capybara'
end

group :test do
  gem 'launchy'    # So you can do Then show me the page
end
