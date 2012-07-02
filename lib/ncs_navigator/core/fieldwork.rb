# -*- coding: utf-8 -*-


require 'ncs_navigator/core'

module NcsNavigator::Core
  module Fieldwork
    autoload :Adapters,      'ncs_navigator/core/fieldwork/adapters'
    autoload :Merge,         'ncs_navigator/core/fieldwork/merge'
    autoload :MergeWorker,   'ncs_navigator/core/fieldwork/merge_worker'
    autoload :ResponseGroup, 'ncs_navigator/core/fieldwork/response_group'
    autoload :Superposition, 'ncs_navigator/core/fieldwork/superposition'
    autoload :Validator,     'ncs_navigator/core/fieldwork/validator'
  end
end
