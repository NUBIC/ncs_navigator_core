require 'ncs_navigator/configuration'

recipients = NcsNavigator.configuration.exception_email_recipients
unless recipients.empty?
  config.middleware.use ExceptionNotifier,
    :email_prefix => NcsNavigatorCore.email_prefix,
    :sender_address => NcsNavigator.configuration.core_mail_from,
    :exception_recipients => recipients
end
