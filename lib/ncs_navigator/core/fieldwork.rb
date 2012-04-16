require 'ncs_navigator/core'

module NcsNavigator::Core
  module Fieldwork
    autoload :Adapters,       'ncs_navigator/core/fieldwork/adapters'
    autoload :Validator,      'ncs_navigator/core/fieldwork/validator'
    autoload :Superposition,  'ncs_navigator/core/fieldwork/superposition'
    autoload :MergeTheirs,    'ncs_navigator/core/fieldwork/merge_theirs'
    autoload :Merge,          'ncs_navigator/core/fieldwork/merge'
  end
end
