Around do |scenario, block|
  conf = NcsNavigator.configuration
  old_id = conf.recruitment_type_id

  begin
    block.call
  ensure
    conf.recruitment_type_id = old_id
  end
end

And /^I am using Two-Tier recruitment$/ do
  NcsNavigator.configuration.recruitment_type_id = 3
end
