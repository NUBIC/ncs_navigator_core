# encoding: utf-8

require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  class UnusedOperationalPassthrough
    include UnusedPassthrough

    STAFF_PORTAL_TABLES = %w(
      staff staff_language staff_cert_training staff_weekly_expense
      staff_exp_mngmnt_tasks staff_exp_data_cllctn_tasks outreach
      outreach_lang2 outreach_race outreach_target outreach_eval
      outreach_staff
    )

    SAMPLING_UNIT_TABLES = %w(study_center psu ssu tsu)

    def filename
      'operational'
    end

    def unused_tables
      operational_tables -
        SAMPLING_UNIT_TABLES -
        STAFF_PORTAL_TABLES -
        OperationalEnumerator.record_producers.collect(&:model).collect(&:mdes_table_name)
    end

    def operational_tables
      @operational_tables ||= NcsNavigatorCore.mdes.
        transmission_tables.select { |t| t.operational_table? }.collect { |t| t.name }
    end
  end
end