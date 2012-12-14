require 'ncs_navigator/core/version'
begin
  Rails.logger.info("NCS Navigator Cases #{NcsNavigator::Core::VERSION} booting. pid: #{$$}, Ruby: #{RUBY_DESCRIPTION}, now: #{Time.now}")
rescue => e
  Rails.logger.info("Logging boot of NCS Navigator Cases failed. #{e.class}: #{e}")
end
