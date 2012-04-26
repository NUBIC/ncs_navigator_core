# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  class UnusedInstrumentPassthrough
    include UnusedPassthrough

    def filename
      'instruments'
    end

    def unused_tables
      Survey.mdes_unused_instrument_tables
    end
  end
end