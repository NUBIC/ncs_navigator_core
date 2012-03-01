require 'aker/authority/ncs_navigator_authority'

NcsNavigatorCore::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.redis_url = 'redis://localhost:6379/'

  config.aker do
    api_mode :cas_proxy
    static = Aker::Authorities::Static.from_file("/etc/nubic/ncs/staff_portal_users.yml")
    authorities :cas, static #, Aker::Authority::NcsNavigatorAuthority
    central '/etc/nubic/ncs/aker-local.yml'
  end
end

require 'openssl'
# This is necessary because there doesn't seem to be a consistent way
# to specify a CA to trust across all the various uses of Net::HTTP in
# all the libraries everywhere.
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE


# Use ruby-debug from Passenger
# http://duckpunching.com/passenger-mod_rails-for-development-now-with-debugger
if File.exists?(File.join(Rails.root, 'tmp', 'debug.txt'))
  require 'ruby-debug'
  Debugger.wait_connection = true
  Debugger.start_remote
  File.delete(File.join(Rails.root, 'tmp', 'debug.txt'))
end
