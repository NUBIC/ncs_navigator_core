require 'ncs_navigator/core/version'
begin
  Rails.logger.info("Booting NCS Navigator Cases #{NcsNavigator::Core::VERSION}")
  Rails.logger.info("  at #{Time.now}")
  Rails.logger.info("  using #{RUBY_ENGINE} #{RUBY_VERSION}-#{RUBY_PATCHLEVEL}")
  Rails.logger.info("  as process #{Process.pid}.")
rescue => e
  Rails.logger.info("Logging boot of NCS Navigator Cases failed. #{e.class}: #{e}")
end
