# -*- coding: utf-8 -*-


require 'ncs_navigator/core'
require 'sidekiq/worker'

module NcsNavigator::Core::Field
  ##
  # Merges fieldwork sets.
  #
  # This worker is triggered by {Api::FieldworkController#update}.
  class MergeWorker
    include Sidekiq::Worker

    def perform(merge_id)
      verify_database_connection

      begin
        ::Merge.find(merge_id).run
      rescue ActiveRecord::StaleObjectError
        retry
      end
    end

    def verify_database_connection
      begin
        ActiveRecord::Base.connection.execute('SELECT 1')
      rescue ActiveRecord::StatementInvalid
        ActiveRecord::Base.connection.reconnect!
      end
    end
  end
end
