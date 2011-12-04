require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  autoload :Enumerator,           'ncs_navigator/core/warehouse/enumerator'
  autoload :EnumeratorHelpers,    'ncs_navigator/core/warehouse/enumerator_helpers'
  autoload :Importer,             'ncs_navigator/core/warehouse/importer'
  autoload :InstrumentEnumerator, 'ncs_navigator/core/warehouse/instrument_enumerator'

  # ResponseSetToWarehouse is not autoloaded because it needs to be
  # explicitly required.
end
