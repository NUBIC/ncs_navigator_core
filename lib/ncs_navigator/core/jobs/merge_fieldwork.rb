# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module NcsNavigator::Core::Jobs
  ##
  # Merges fieldwork sets.
  #
  # This job is triggered by {Api::FieldworkController#update}.
  class MergeFieldwork
    include Sidekiq::Worker

    def perform(fieldwork_id)
      verify_database_connection

      fw = Fieldwork.find(fieldwork_id)

      fw.merge
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
