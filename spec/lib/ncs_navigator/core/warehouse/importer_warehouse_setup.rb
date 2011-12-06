require 'spec_helper'

shared_context :importer_spec_warehouse do
  before(:all) do
    wh_init.set_up_repository(:both)
    wh_init.replace_schema
    DatabaseCleaner[:data_mapper].strategy = :transaction
  end

  # This is not a `let` due to https://github.com/rspec/rspec-core/issues/500
  def wh_config
    @wh_config ||= NcsNavigator::Warehouse::Configuration.new.tap do |config|
      config.log_file = File.join(Rails.root, 'log/wh-import_test.log')
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

  # This is not a `let` due to https://github.com/rspec/rspec-core/issues/500
  def wh_init
    @wh_init ||= NcsNavigator::Warehouse::DatabaseInitializer.new(wh_config)
  end

  # This is not a `let` due to https://github.com/rspec/rspec-core/issues/500
  def bcdatabase_config
    @bcdatabase_config ||=
      if Rails.env == 'ci'
        { :group => :public_ci_postgresql9 }
      else
        { :name => :ncs_navigator_core_test }
      end
  end
end
