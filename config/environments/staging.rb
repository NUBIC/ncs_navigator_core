# encoding: utf-8

require 'aker/authority/ncs_navigator_authority'

NcsNavigatorCore::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  config.assets.js_compressor  = :uglifier

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Compress JavaScript and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.aker do
    api_mode :cas_proxy
    authorities :cas, Aker::Authority::NcsNavigatorAuthority
    central '/etc/nubic/ncs/aker-staging.yml'
  end

  config.middleware.use ExceptionNotifier,
    :email_prefix => "[NCS Navigator Core] ",
    :sender_address => %{"Paul Friedman" <p-friedman@northwestern.edu>},
    :exception_recipients => %w{p-friedman@northwestern.edu r-sutphin@northwestern.edu}

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "ns.northwestern.edu", :port => 25, :domain => "northwestern.edu" }

  config.redis_url = 'redis://ncsdb-staging:6379/'
end