require 'ncs_navigator/core'

module NcsNavigator::Core
  module Mdes
    autoload :CodeListLoader, 'ncs_navigator/core/mdes/code_list_loader'

    autoload :HumanReadablePublicIdGenerator, 'ncs_navigator/core/mdes/human_readable_public_id_generator'
    autoload :InstrumentOwner, 'ncs_navigator/core/mdes/instrument_owner'
    autoload :MdesDate,        'ncs_navigator/core/mdes/mdes_date'
    autoload :MdesRecord,      'ncs_navigator/core/mdes/mdes_record'

    autoload :Version,           'ncs_navigator/core/mdes/version'
    autoload :VersionMigrator,   'ncs_navigator/core/mdes/version_migrator'
    autoload :VersionMigrations, 'ncs_navigator/core/mdes/version_migrations'
  end
end
