Given /^the NCS codes were last modified on "([^"]*)"$/ do |datetime|
  NcsCode.update_all(:updated_at => Time.parse(datetime))
end

Given /^the MDES disposition codes were last modified on "([^"]*)"$/ do |datetime|
  raise "@tmpdir not set" unless @tmpdir

  fn = "#{@tmpdir}/test_disposition_codes.yml"
  touch fn, :mtime => Time.parse(datetime)

  NcsNavigatorCore.configuration.mdes.source_documents.disposition_codes = fn
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

Then /^the response body contains MDES disposition codes$/ do
  json['disposition_codes'].should_not be_blank
end
