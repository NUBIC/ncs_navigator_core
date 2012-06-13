# -*- coding: utf-8 -*-

require 'spec_helper'
require Rails.root + 'spec/warehouse_setup'

shared_context :importer_spec_warehouse do
  include NcsNavigator::Core::Spec::WarehouseSetup

  before(:all) do
    wh_init.set_up_repository(:both)
    DatabaseCleaner[:data_mapper].strategy = :transaction
  end

  def all_missing_attributes(model)
    coded_missing = model.properties.
      select { |p| p.required? && p.options[:set] }.
      inject({}) { |h, prop| h[prop.name] = '-4'; h }

    text_missing = model.properties.
      select { |p| p.required? && !p.options[:set] }.
      inject({}) { |h, prop| h[prop.name] = 'NA'; h }

    coded_missing.merge(text_missing).merge(:psu_id => '20000030')
  end
end
