require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  autoload :DatabaseEnumeratorHelpers, 'ncs_navigator/core/warehouse/database_enumerator_helpers'
  autoload :InstrumentEnumerator,      'ncs_navigator/core/warehouse/instrument_enumerator'
  autoload :OperationalEnumerator,     'ncs_navigator/core/warehouse/operational_enumerator'
  autoload :OperationalImporter,       'ncs_navigator/core/warehouse/operational_importer'

  # ResponseSetToWarehouse is not autoloaded because it needs to be
  # explicitly required.
end
