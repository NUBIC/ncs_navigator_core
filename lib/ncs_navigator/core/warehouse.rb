require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'

module NcsNavigator::Core::Warehouse
  autoload :Transformer,        'ncs_navigator/core/warehouse/transformer'
  autoload :TransformerHelpers, 'ncs_navigator/core/warehouse/transformer_helpers'
end
