require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes
  module VersionMigrations
    autoload :Basic,               'ncs_navigator/core/mdes/version_migrations/basic'
    autoload :ThreeZeroToThreeTwo, 'ncs_navigator/core/mdes/version_migrations/three_zero_to_three_two'
  end
end
