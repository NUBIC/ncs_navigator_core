# -*- coding: utf-8 -*-


require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  autoload :ArchivalStaffAndOutreachPassthrough, 'ncs_navigator/core/warehouse/archival_staff_and_outreach_passthrough'
  autoload :DatabaseEnumeratorHelpers,           'ncs_navigator/core/warehouse/database_enumerator_helpers'
  autoload :InstrumentEnumerator,                'ncs_navigator/core/warehouse/instrument_enumerator'
  autoload :LegacyInstrumentEnumerator,          'ncs_navigator/core/warehouse/legacy_instrument_enumerator'
  autoload :LegacyInstrumentImporter,            'ncs_navigator/core/warehouse/legacy_instrument_importer'
  autoload :OperationalEnumerator,               'ncs_navigator/core/warehouse/operational_enumerator'
  autoload :OperationalImporter,                 'ncs_navigator/core/warehouse/operational_importer'
  autoload :OperationalImporterPscSync,          'ncs_navigator/core/warehouse/operational_importer_psc_sync'
  autoload :TwoPointOne,                         'ncs_navigator/core/warehouse/two_point_one'
  autoload :TwoPointTwo,                         'ncs_navigator/core/warehouse/two_point_two'
  autoload :TwoPointZero,                        'ncs_navigator/core/warehouse/two_point_zero'
  autoload :ThreePointOne,                       'ncs_navigator/core/warehouse/three_point_one'
  autoload :ThreePointTwo,                       'ncs_navigator/core/warehouse/three_point_two'
  autoload :ThreePointZero,                      'ncs_navigator/core/warehouse/three_point_zero'
  autoload :UnusedOperationalPassthrough,        'ncs_navigator/core/warehouse/unused_operational_passthrough'
  autoload :UnusedPassthrough,                   'ncs_navigator/core/warehouse/unused_passthrough'

  # InstrumentToWarehouse is not autoloaded because it needs to be
  # explicitly required.
end
