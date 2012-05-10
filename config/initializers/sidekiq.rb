# -*- coding: utf-8 -*-

##
# NB: This is in an after_initialize block because we need
# deferrable_redis_connection.rb to have run before we do any Resque configuration.
Rails.application.config.after_initialize do
  Sidekiq.configure_client do |config|
    config.redis = { :url => Rails.application.redis_url, :namespace => 'nubic:ncs_navigator_core:sidekiq', :size => 1 }
  end

  Sidekiq.configure_server do |config|
    config.redis = { :url => Rails.application.redis_url, :namespace => 'nubic:ncs_navigator_core:sidekiq' }
  end
end
