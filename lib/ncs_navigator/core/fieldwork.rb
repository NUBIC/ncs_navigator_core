require 'ncs_navigator/core'

module NcsNavigator::Core
  module Fieldwork
    autoload :Validator,      'ncs_navigator/core/fieldwork/validator'
    autoload :Superposition,  'ncs_navigator/core/fieldwork/superposition'
    autoload :MergeTheirs,    'ncs_navigator/core/fieldwork/merge_theirs'
  end
end
