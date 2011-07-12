require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

When /^I wait (\d+) seconds$/ do |wait_seconds|
  sleep(wait_seconds.to_i)
end

Given /^the following (.+) records:$/ do |factory, table|
  table.hashes.each do |hash|
    Factory(factory.to_sym, hash)
  end
end
