source 'http://rubygems.org'

gem 'rails', '3.1.1'

gem 'bcdatabase', '~> 1.0'
gem 'aker', '~> 3.0'
gem 'aker-rails'
gem 'compass'
gem 'fastercsv'
gem 'haml', '~> 3.1'
gem 'pg'

gem 'exception_notification', :require => 'exception_notifier'
gem 'ransack'
gem 'foreigner'

group :assets do
  gem 'sass-rails', "~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'
gem 'json-schema'

gem 'ncs_mdes', '~> 0.5'
gem 'formtastic', '1.2.4'
gem 'surveyor', :git => 'git://github.com/NUBIC/surveyor.git'
gem 'psc'
gem 'ncs_navigator_configuration'

gem 'state_machine'
gem 'state_machine-audit_trail'
gem 'uuid'
gem 'will_paginate'
gem 'faraday'

gem 'redis'

group :development do
  gem 'capistrano'
  gem 'watchr'

  gem 'ruby-debug', :platform => :ruby_18
end

group :osx_development do
  gem 'rb-fsevent'
end

group :staging, :production do
  gem 'therubyracer'
end

gem 'ncs_mdes_warehouse',
  :git => 'git://github.com/NUBIC/ncs_mdes_warehouse.git'
#gem 'ncs_mdes_warehouse', '~> 0.3', '>= 0.3.2'
gem 'aker-cas_cli', :git => 'git://github.com/NUBIC/aker-cas_cli.git',
  :require => false
gem 'dm-ar-finders', '~> 1.2.0'

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

  gem 'ci_reporter'
end

group :test, :ci do
  gem 'cucumber'
  gem 'cucumber-rails', :require => false
  # database_cleaner 0.6.7 doesn't work with DataMapper on PostgreSQL
  gem 'database_cleaner', :git => 'git://github.com/bmabey/database_cleaner.git'
  gem 'shoulda'
  gem 'factory_girl'
  gem 'rcov'
  gem 'pickle'
  gem 'vcr'
  gem 'fakeweb'

  gem "spork", "> 0.9.0.rc"
  gem "guard-spork"

  gem 'capybara'
  gem 'rack-test'
end

group :test do
  gem 'launchy'    # So you can do Then show me the page
end
