Given /^the NCS codes were last modified on "([^"]*)"$/ do |datetime|
  NcsCode.update_all(:updated_at => Time.parse(datetime))
end

Then /^the response body contains the MDES version$/ do
  json['mdes_version'].should == NcsNavigatorCore.configuration.mdes.version
end

Then /^the response body contains the MDES specification version$/ do
  json['mdes_specification_version'].should ==
    NcsNavigatorCore.configuration.mdes.specification_version
end

Then /^the response body contains NCS codes$/ do
  json['ncs_codes'].should_not be_blank
end
