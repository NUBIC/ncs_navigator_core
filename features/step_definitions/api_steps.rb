When /^I PUT ([^\s]+) with$/ do |url, payload|
  put url, payload, 'Content-Type' => 'application/json'
end

When /^I GET the referenced location$/ do
  raise 'No Location header found in the response' unless headers.has_key?('Location')

  location = response_headers['Location']

  raise 'Response contains a blank location' if location.blank?

  get location
end

Then /^the response status is (\d+)$/ do |status|
  status_code.should == status.to_i
end

Then /^the response body satisfies$/ do |table|
  body = JSON.parse(response_body)
  actual = {}

  table.hashes.each do |key, value|
    body[key] = value
  end

  table.diff!(actual)
end
