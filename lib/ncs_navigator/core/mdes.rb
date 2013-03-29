require 'ncs_navigator/core'

module NcsNavigator::Core
  module Mdes
    ##
    # All the MDES versions supported by this version of Cases.
    SUPPORTED_VERSIONS = %w(2.0 2.1 2.2 3.0 3.1 3.2).freeze

    autoload :CodeListCache,  'ncs_navigator/core/mdes/code_list_cache'
    autoload :CodeListLoader, 'ncs_navigator/core/mdes/code_list_loader'

    autoload :HumanReadablePublicIdGenerator, 'ncs_navigator/core/mdes/human_readable_public_id_generator'
    autoload :InstrumentOwner,   'ncs_navigator/core/mdes/instrument_owner'
    autoload :MdesDate,          'ncs_navigator/core/mdes/mdes_date'
    autoload :MdesRecord,        'ncs_navigator/core/mdes/mdes_record'
    autoload :NcsCodedAttribute, 'ncs_navigator/core/mdes/ncs_coded_attribute'

    autoload :Version,           'ncs_navigator/core/mdes/version'
    autoload :VersionMigrator,   'ncs_navigator/core/mdes/version_migrator'
    autoload :VersionMigrations, 'ncs_navigator/core/mdes/version_migrations'
  end
end
