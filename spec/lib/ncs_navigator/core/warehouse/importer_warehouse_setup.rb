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
    model.properties.
      select { |p| p.required? }.
      inject({}) { |h, prop| h[prop.name] = missing_value_for_property(prop); h }.
      merge(:psu_id => '20000030')
  end

  def missing_value_for_property(dm_prop)
    if dm_prop.options[:set]
      '-4'
    elsif dm_prop.class < ::DataMapper::Property::Numeric
      0
    else
      'NA'
    end
  end
end
