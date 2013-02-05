# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module NcsNavigator::Core
  module Field
    autoload :JSONValidator, 'ncs_navigator/core/field/json_validator'
    autoload :LogDevice,     'ncs_navigator/core/field/log_device'
    autoload :LogFormatter,  'ncs_navigator/core/field/log_formatter'
    autoload :MergeWorker,   'ncs_navigator/core/field/merge_worker'
  end
end
