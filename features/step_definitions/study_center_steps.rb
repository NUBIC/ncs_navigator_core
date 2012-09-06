Around do |scenario, block|
  config = NcsNavigatorCore.configuration
  old_with_specimens = config.with_specimens?

  begin
    block.call
  ensure
    config.suite_configuration.core["with_specimens"] = old_with_specimens.to_s
  end
end

Given /^the study center collects specimens$/ do
  NcsNavigatorCore.configuration.suite_configuration.core["with_specimens"] = 'true'
end
