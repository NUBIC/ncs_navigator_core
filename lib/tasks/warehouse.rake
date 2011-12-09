desc 'Rebuild the test warehouse schema'
task 'db:test:prepare:warehouse' => :environment do
  require Rails.root + 'spec/warehouse_setup.rb'
  NcsNavigator::Core::Spec::WarehouseSetup.wh_config.output_level = :normal
  NcsNavigator::Core::Spec::WarehouseSetup.wh_init.tap do |init|
    init.set_up_repository(:both)
    init.replace_schema
  end
end
