recipients = NcsNavigator.configuration.exception_email_recipients
unless recipients.empty?
  Rails.application.config.middleware.insert_before 'Rack::Runtime', ExceptionNotifier,
    :email_prefix => NcsNavigatorCore.email_prefix,
    :sender_address => NcsNavigatorCore.suite_configuration.core_mail_from,
    :exception_recipients => recipients
end
