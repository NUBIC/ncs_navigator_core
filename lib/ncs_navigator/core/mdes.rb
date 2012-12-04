require 'ncs_navigator/core'

module NcsNavigator::Core
  module Mdes
    autoload :MdesDate,   'ncs_navigator/core/mdes/mdes_date'
    autoload :MdesRecord, 'ncs_navigator/core/mdes/mdes_record'
    autoload :HumanReadablePublicIdGenerator, 'ncs_navigator/core/mdes/human_readable_public_id_generator'

    autoload :Version, 'ncs_navigator/core/mdes/version'
  end
end
