# -*- coding: utf-8 -*-


require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  autoload :DatabaseEnumeratorHelpers,    'ncs_navigator/core/warehouse/database_enumerator_helpers'
  autoload :InstrumentEnumerator,         'ncs_navigator/core/warehouse/instrument_enumerator'
  autoload :LegacyInstrumentImporter,     'ncs_navigator/core/warehouse/legacy_instrument_importer'
  autoload :OperationalEnumerator,        'ncs_navigator/core/warehouse/operational_enumerator'
  autoload :OperationalImporter,          'ncs_navigator/core/warehouse/operational_importer'
  autoload :OperationalImporterPscSync,   'ncs_navigator/core/warehouse/operational_importer_psc_sync'
  autoload :UnusedOperationalPassthrough, 'ncs_navigator/core/warehouse/unused_operational_passthrough'
  autoload :UnusedPassthrough,            'ncs_navigator/core/warehouse/unused_passthrough'

  # InstrumentToWarehouse is not autoloaded because it needs to be
  # explicitly required.
end
