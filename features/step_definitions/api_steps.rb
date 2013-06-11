# -*- coding: utf-8 -*-

require 'hana'
require 'rack/test'

# For API tests, it's nice to have more direct control over the HTTP request and
# response.
#
# We obtain this control by creating delegators that interact directly with
# Capybara's Rack::Test session.  This is a pretty gross hack, but it works.
# (For now.)
Before '@api' do
  raise "API tests must use the rack-test driver" if Capybara.current_driver != :rack_test

  def api?
    true
  end

  def browser
    Capybara.current_session.driver.browser
  end

  class << self
    extend Forwardable

    def_delegators :browser, *Rack::Test::Methods::METHODS
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

# We cannot write this in Gherkin:
#
#     When I PUT /api/v1/fieldwork/foo with
#     """
#     { ... }
#     """
#     with headers
#       | foo | bar |
#
# because steps cannot accept both a string and table.  Therefore, we break it
# up into multiple steps.
When /^the payload(?: is)?$/ do |string|
  @payload = string
end

When /^I PUT the payload to ([^\s]+)$/ do |url|
  put url, @payload
end

When /^I PUT the payload to ([^\s]+) with$/ do |url, table|
  params, headers = params_and_headers_from_table(table)
  headers.each { |k, v| header(k, v) }

  put url, @payload, params
end

When /^I POST ([^\s]+) with$/ do |url, table|
  header 'Content-Type', 'application/x-www-form-urlencoded'

  params, headers = params_and_headers_from_table(table)
  headers.each { |k, v| header(k, v) }

  post url, params
end

When /^I GET ([^\s]+)$/ do |url|
  get url
end

When /^I GET ([^\s]+) with$/ do |url, table|
  params, headers = params_and_headers_from_table(table)
  headers.each { |k, v| header(k, v) }

  get url, params
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
  json = JSON.parse(last_response.body)

  actual = table.raw.each.with_object([]) do |(key, value), obj|
    ptr = Hana::Pointer.new(key)
    val = ptr.eval(json)

    obj << [key, val.to_s]
  end

  table.diff!(actual)
end

Then /^the response body matches$/ do |string|
  expected = JSON.parse(string)

  json.diff(expected).should == {}
end

Then /^the referenced entity is a fieldwork set$/ do
  location = last_response.headers['Location']
  raise 'Response contains a blank location' if location.blank?

  get location
end

Then /^the response is a fieldwork set$/ do
  last_response.body.should be_a_fieldwork_set
end

Then /^the response contains a reference to itself$/ do
  original_set = last_response.body

  location = last_response.headers['Location']
  raise 'Response contains a blank location' if location.blank?

  get location

  json.should == JSON.parse(original_set)
end

Then /^the response body satisfies the (.+) schema$/ do |schema|
  fn = case schema
       when 'providers'; 'providers_schema.json'
       when 'code lists'; 'code_lists_schema.json'
       when 'event search'; 'events_schema.json'
       when 'fieldwork'; 'fieldwork_schema.json'
       else raise %Q{Cannot map "#{schema}" to a schema filename}
       end

  fp = File.expand_path("../../../vendor/ncs_navigator_schema/#{fn}", __FILE__)

  v = NcsNavigator::Core::Field::JSONValidator.new(fp)
  report = v.validate(last_response.body)

  if report.has_errors?
    report.errors.each { |e| puts e.inspect }
    raise "Response body should have conformed to the schema defined by #{fn}"
  end
end
