require 'ncs_navigator/core'

module NcsNavigator::Core::Fieldwork
  ##
  # A merge strategy that unconditionally accepts proposed changes.
  module MergeTheirs
    def merge
    end
  end
end
