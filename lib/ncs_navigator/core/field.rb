# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module NcsNavigator::Core
  module Field
    autoload :LogDevice,     'ncs_navigator/core/field/log_device'
    autoload :MergeWorker,   'ncs_navigator/core/field/merge_worker'
    autoload :Validator,     'ncs_navigator/core/field/validator'
  end
end
