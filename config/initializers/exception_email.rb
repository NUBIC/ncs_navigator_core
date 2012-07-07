recipients = NcsNavigator.configuration.exception_email_recipients
unless recipients.empty?
  Rails.application.config.middleware.insert_before 'Rack::Runtime', ExceptionNotifier,
    :email_prefix => NcsNavigatorCore.email_prefix,
    :sender_address => NcsNavigatorCore.suite_configuration.core_mail_from,
    :exception_recipients => recipients

  class NcsNavigator::Core::ExceptionGeneratingMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      aker = env['aker.check']
      if env['PATH_INFO'] == '/admin/fail' && aker && aker.permit?('System Administrator')
        fail "One exception, coming up"
      end
      @app.call(env)
    end
  end

  Rails.application.config.middleware.use NcsNavigator::Core::ExceptionGeneratingMiddleware
end
