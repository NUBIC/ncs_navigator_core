source 'http://rubygems.org'
source 'http://download.bioinformatics.northwestern.edu/gems'

gem 'rails', '3.1.0'

gem 'bcdatabase', '~> 1.0.5'
gem 'aker', '~> 3.0'
gem 'aker-rails'
gem 'compass'
gem 'fastercsv'
gem 'haml', '~> 3.1'
gem 'pg'
gem 'ruby-debug'
gem 'jquery-rails'

gem 'ncs_mdes', '0.4.0'
gem 'surveyor', :git => 'git://github.com/NUBIC/surveyor.git', :branch => 'rails3'
gem 'psc'
gem 'ncs_navigator_configuration'

gem 'state_machine'
gem 'state_machine-audit_trail'
gem 'uuid'
gem 'will_paginate'


group :development do
  gem 'watchr'
  gem 'rb-fsevent'
  gem 'growl_notify' # or gem 'growl'
end

group :development, :test, :ci do
  gem 'rspec-rails', '~> 2.4'
  
  gem 'guard'
  gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-coffeescript'
  gem 'guard-livereload'
  gem 'guard-bundler'
  gem 'jasmine'
  
end

group :test, :ci, :cucumber do

  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl'
  gem 'rcov'
  gem 'pickle'
  gem 'vcr'
  gem 'fakeweb'

end

group :cucumber do
  gem 'capybara'
  gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
end