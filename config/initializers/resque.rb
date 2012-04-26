# -*- coding: utf-8 -*-


##
# NB: This is in an after_initialize block because we need
# deferrable_redis_connection.rb to have run before we do any Resque configuration.
#
# Lexicographical ordering means we're fine for now (d < r), but why rely on
# that when you don't have to?
Rails.application.config.after_initialize do
  Resque.redis = Rails.application.redis_url
  Resque.redis.namespace = 'nubic:ncs_navigator_core:resque'
end