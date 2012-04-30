require 'ncs_navigator/configuration'
require "#{Rails.root}/lib/development_mail_interceptor"

ActionMailer::Base.smtp_settings = NcsNavigator.configuration.action_mailer_smtp_settings
ActionMailer::Base.default :from => NcsNavigator.configuration.core['mail_from']
ActionMailer::Base.default_url_options[:host] = NcsNavigator.configuration.corel_uri.host

if Rails.env.development?
  ActionMailer::Base.default_url_options[:port] = "3000"
  Mail.register_interceptor(DevelopmentMailInterceptor)
end