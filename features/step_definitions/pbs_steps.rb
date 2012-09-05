Around do |scenario, block|
  conf = NcsNavigator.configuration
  old_id = conf.recruitment_type_id

  begin
    block.call
  ensure
    conf.recruitment_type_id = old_id
  end
end

Given /^I am using PBS recruitment$/ do
  NcsNavigator.configuration.recruitment_type_id = 5
end

When /^I browse for \.csv file$/ do
 attach_file("file", File.join(::Rails.root, 'spec', 'fixtures', 'data', 'pbs_list_table_test_20120619.csv'))
end

Given /^valid PBS List record$/ do
  pbs_list = Factory(:pbs_list)
end


