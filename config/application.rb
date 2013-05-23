# -*- coding: utf-8 -*-


require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "sass-rails" # add this here

if defined?(Bundler)
  # If you precompile assets before deploying to production,
  #  use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production,
  #  use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module NcsNavigatorCore
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    # config.autoload_paths += %W(#{Rails.root}/app/models/data_extractors)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :merge_observer
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Enable asset pipeline
    config.assets.enabled = true

    # add these three lines:
    config.sass.load_paths ||= []
    config.sass.load_paths << "#{Rails.root}/app/assets/stylesheets"
    config.sass.load_paths << "#{Gem.loaded_specs['compass'].full_gem_path}/frameworks/compass/stylesheets"

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, 'CORE_SECRET']

    Aker.configure do
      # The authentication protocol to use for interactive access.
      # `:form` is the default.
      ui_mode :cas

      # The authentication protocol(s) to use for non-interactive
      # access.  There is no default.
      # api_mode :http_basic

      # The portal to which this application belongs.  Optional.
      portal :NCSNavigator
    end

    def csv_impl
      @csv_impl ||= if RUBY_VERSION < '1.9'
                       require 'fastercsv'
                       FasterCSV
                     else
                       require 'csv'
                       CSV
                     end
    end

    def code_list_cache
      @code_list_cache ||= NcsNavigator::Core::Mdes::CodeListCache.new
    end
  end

  # This is done here instead of in an initializer so that all
  # initializers have access to the configuration methods.
  class << self
    # require needs to wait until Rails has set up the load path
    require 'ncs_navigator/core'

    # Logger used by the {PatientStudyCalendar} instances built by
    # {ApplicationController#psc}.
    attr_accessor :psc_logger

    ##
    # The recruitment strategy used by this Cases instance.
    #
    # Settable for testing.  In a production environment, this shouldn't be
    # changed after initialization.
    attr_accessor :recruitment_strategy

    extend Forwardable

    # All of the configuration methods were moved to
    # NcsNavigator::Core::Configuration. This module delegates to them
    # as a shim, both for backwards compatibility and to make
    # invocations shorter.
    def_delegators :configuration,
      *NcsNavigator::Core::Configuration.public_instance_methods(false);

    def configuration
      NcsNavigator::Core::Configuration.instance
    end
  end
end

require 'patient_study_calendar'
require 'recruitment_strategy'

require 'ncs_navigator/core'
require 'ncs_navigator/mdes_ext'

require 'ncs_navigator/core/redis_configuration'
require 'ncs_navigator/core/sidekiq_configuration'
