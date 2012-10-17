# coding: utf-8

require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  ##
  # An adapter module which exposes the same class-level interface
  # as any MDES-version-specific OperationalEnumerator.
  module OperationalEnumerator
    class << self
      def select_implementation(warehouse_configuration)
        module_name = warehouse_configuration.models_module.to_s.split('::').last

        begin
          mod = NcsNavigator::Core::Warehouse.const_get(module_name)
          mod.const_get(:OperationalEnumerator)
        rescue NameError => e
          fail "Cases has no operational enumerator for MDES #{warehouse_configuration.mdes_version}. (#{e})"
        end
      end

      def create_transformer(warehouse_configuration, options={})
        select_implementation(warehouse_configuration).create_transformer(warehouse_configuration, options)
      end
    end
  end
end
