require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  class ArchivalStaffAndOutreachPassthrough
    include UnusedPassthrough

    def filename
      'archived_staff_and_outreach'
    end

    def unused_tables
      OPS_TABLES
    end
  end
end
