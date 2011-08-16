source 'http://rubygems.org'
source 'http://download.bioinformatics.northwestern.edu/gems'

gem 'rails', '3.0.7'

gem 'bcdatabase', '~> 1.0.5'
gem 'aker', '~> 3.0'
gem 'aker-rails'
gem 'compass'
gem 'fastercsv'
gem 'haml', '~> 3.1'
gem 'pg'
gem 'ruby-debug'

gem 'ncs_mdes', '0.4.0'
gem "surveyor", :git => "git://github.com/NUBIC/surveyor.git", :branch => "rails3"

gem 'uuid'
gem 'will_paginate', '~> 3.0'

group :development do
  gem 'watchr'
end

group :development, :test, :ci do
  gem 'rspec-rails', '~> 2.4'
end

group :test, :ci, :cucumber do

  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl'
  gem 'rcov'
  gem 'pickle'

end

group :cucumber do
  gem 'capybara'
  gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
end