require 'rack/test'

# For API tests, it's nice to have more direct control over the HTTP request and
# response.  Rack::Test is therefore used directly in those tests.
Before '@api' do
  extend Rack::Test::Methods

  class << self
    def api?
      true
    end

    def app
      NcsNavigatorCore::Application
    end
  end

  # All API services, by default, require the client to accept and send JSON.
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
end

# For tests that test pages, we're more interested in simulating a browser.  To
# do that in an Aker-protected application that supplies both human-consumable
# pages and API endpoints, we need to use interactive authentication.  One way
# to do that is to state that we accept HTML.
#
# Because Capybara is such a high-level abstraction, it's not always possible to
# set request headers.  Fortunately:
#
# 1) The Rack::Test driver allows us to set headers via an options method, and
#    that's the driver that's used for the majority of integration tests.
# 2) Those drivers that don't permit it (viz. Selenium) drive real Web browsers.
Before '~@api' do
  if Capybara.current_driver == :rack_test
    driver = Capybara.current_session.driver

    driver.options[:headers] ||= {}
    accept = driver.options[:headers]['HTTP_ACCEPT'] || ''

    driver.options[:headers]['HTTP_ACCEPT'] = (accept.split(',') << 'text/html').join(',')
  end
end

When /^I PUT ([^\s]+) with$/ do |url, payload|
  put url, payload
end

When /^I GET ([^\s]+)$/ do |url|
  get url
end

When /^I GET the referenced location$/ do
  headers = last_response.headers

  raise 'No Location header found in the response' unless headers.has_key?('Location')

  location = headers['Location']

  raise 'Response contains a blank location' if location.blank?

  get location
end

Then /^the response status is (\d+)$/ do |status|
  last_response.status.should == status.to_i
end

Then /^the response body satisfies$/ do |table|
  body = JSON.parse(last_response.body)
  actual = [['key', 'value']]

  table.hashes.each do |hash|
    actual << [hash['key'], body[hash['key']]]
  end

  table.diff!(actual)
end

Then /^the response body is$/ do |string|
  last_response.body.should == string
end
