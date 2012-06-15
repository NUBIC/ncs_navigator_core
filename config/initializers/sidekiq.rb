# -*- coding: utf-8 -*-

Sidekiq.configure_client do |config|
  config.redis = { :url => Rails.application.redis_url, :namespace => 'nubic:ncs_navigator_core:sidekiq', :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :url => Rails.application.redis_url, :namespace => 'nubic:ncs_navigator_core:sidekiq' }
end
