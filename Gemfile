source 'http://rubygems.org'

gem 'rails', '3.1.10'

gem 'active_model_serializers'
gem 'bcdatabase', '~> 1.0'
gem 'aker', '~> 3.0'
gem 'aker-rails'
gem 'case'
gem 'celluloid', '>= 0.12.0'
gem 'clockwork'
gem 'chronic'
gem 'comma'
gem 'dante'
gem 'fastercsv', :platform => :ruby_18
gem 'haml', '~> 3.1'
gem 'lograge'
gem 'pg'
gem 'ncs_navigator_authority'

gem 'exception_notification', :require => 'exception_notifier'
gem 'paper_trail', '~> 2'
gem 'ransack'
gem 'foreman'
gem 'foreigner'
gem 'facets', :require => false

group :assets do
  # sass-rails 3.1.6 induces indefinite recursion during
  # assets:precompile under capistrano.
  # Related (but not exactly the same problem we saw):
  #  https://github.com/rails/sass-rails/commit/0b435834bc37e26c016f2d29885ca3bfe08ae827
  gem 'sass-rails', "~> 3.1.0", "!= 3.1.6"
  gem 'compass-rails'
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'
gem 'json-schema'

gem 'ncs_mdes', '>= 0.11.0'
# If you change surveyor, change the instruments project also
gem 'surveyor', '~> 1.2.0'
gem 'psc'
gem 'ncs_navigator_configuration', :git => 'https://github.com/NUBIC/ncs_navigator_configuration.git'
gem 'sidekiq'

gem 'state_machine'
gem 'state_machine-audit_trail'
gem 'uuidtools'
gem 'will_paginate'
gem 'faraday'

gem 'mustache'

gem 'redis'

group :development do
  gem 'capistrano'
  gem 'debugger'
end

group :osx_development do
  gem 'rb-fsevent'
end

group :staging, :production do
  gem 'therubyracer'
end

gem 'ncs_mdes_warehouse', '~> 0.10', '>= 0.10.1'
gem 'aker-cas_cli', '~> 1.0', :require => false
gem 'dm-ar-finders', '~> 1.2.0'

group :development, :test, :ci do
  gem 'annotate', '~> 2.5.0'
  gem 'rspec-rails', '2.6.1'

  gem 'guard'
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-coffeescript'
  gem 'guard-livereload'
  gem 'guard-bundler'
  gem 'jasmine'
  gem 'perftools.rb'

  gem 'ci_reporter'
end

group :test, :ci do
  gem 'cucumber', '~> 1.1.9'
  gem 'cucumber-rails', :require => false
  # See https://github.com/bmabey/database_cleaner/pull/119
  gem 'database_cleaner',
    :git => 'git://github.com/rsutphin/database_cleaner.git', :branch => 'dm-pg-single-trunc'
  gem 'hana'
  gem 'shoulda'
  gem 'factory_girl', '~> 2.6'
  gem 'simplecov', :require => false
  gem 'pickle'
  gem 'vcr', '~> 2.4'
  gem 'fakeweb'
  gem 'webmock', :require => false

  gem "spork", "> 0.9.0.rc"
  gem "guard-spork"

  gem 'capybara'
  gem 'rack-test'

  platform :ruby_19 do
    gem 'test-unit', '= 2.4.8', :require => 'test/unit'
  end
end

group :test do
  gem 'launchy'    # So you can do Then show me the page
end
