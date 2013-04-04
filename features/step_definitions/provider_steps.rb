Given /^there exists a provider$/ do
  Factory(:provider,
    :address => Factory(:address, :address_one => '321 Contact Rd.', :unit => 'A'))
end

Given /^the providers were last modified on "([^"]*)"$/ do |datetime|
  Provider.update_all(:updated_at => Time.parse(datetime))
end

Then /^the response body contains providers$/ do
  json['providers'].should_not be_blank
end
