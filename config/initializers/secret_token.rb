# -*- coding: utf-8 -*-

# Be sure to restart your server when you modify this file.

default_secret = 'cases' * 30
secret_name = 'CORE_SECRET'

if %w(development test ci).include?(Rails.env)
  NcsNavigatorCore::Application.config.secret_token = ENV[secret_name] || default_secret
else
  NcsNavigatorCore::Application.config.secret_token = ENV[secret_name] ||
    fail("#{secret_name} is mandatory for #{Rails.env}")
end
