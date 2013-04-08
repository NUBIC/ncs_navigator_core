# -*- coding: utf-8 -*-


require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  class UnusedOperationalPassthrough
    include UnusedPassthrough

    SAMPLING_UNIT_TABLES = %w(study_center psu ssu tsu)

    def filename
      'operational'
    end

    def unused_tables
      operational_tables -
        SAMPLING_UNIT_TABLES -
        OPS_TABLES -
        operational_enumerator.record_producers.collect { |rp| rp.model(@wh_config) }.collect(&:mdes_table_name)
    end

    def operational_tables
      @operational_tables ||= @wh_config.mdes.
        transmission_tables.select { |t| t.operational_table? }.collect { |t| t.name }
    end

    def operational_enumerator
      OperationalEnumerator.select_implementation(@wh_config)
    end
    private :operational_enumerator
  end
end
