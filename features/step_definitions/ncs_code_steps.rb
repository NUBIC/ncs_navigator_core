Given /^the NCS codes were last modified on "([^"]*)"$/ do |datetime|
  NcsCode.update_all(:updated_at => Time.parse(datetime))
end
