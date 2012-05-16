# -*- coding: utf-8 -*-

require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Spec
  module WarehouseSetup
    # This configuration is only used for tests for components that
    # read from the warehouse.
    def wh_config
      @wh_config ||= NcsNavigator::Warehouse::Configuration.new.tap do |config|
        config.log_file = Rails.root + 'log/wh-import_test.log'
        config.set_up_logs
        config.output_level = :quiet
        if bcdatabase_config[:group]
          config.bcdatabase_group = bcdatabase_config[:group]
        end
        config.bcdatabase_entries.merge!(
          # these are deliberately the same since replace_schema only
          # works on the working database, while the importer runs
          # against the reporting database.
          :working   => :ncs_navigator_core_test_mdes_warehouse,
          :reporting => :ncs_navigator_core_test_mdes_warehouse
          )
      end
    end

    def wh_init
      @wh_init ||= NcsNavigator::Warehouse::DatabaseInitializer.new(wh_config)
    end

    def bcdatabase_config
      @bcdatabase_config ||=
        case Rails.env
        when 'ci'
          { :group => 'public_ci_postgresql9' }
        when 'ci_warehouse'
          { :group => 'public_ci_postgresql9', :name => 'ncs_navigator_core_wh' }
        else
          { :name => 'ncs_navigator_core_test' }
        end
    end

    module_function :wh_config, :wh_init, :bcdatabase_config
  end
end
