require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes
  module VersionMigrations
    autoload :Basic,               'ncs_navigator/core/mdes/version_migrations/basic'
    autoload :TwoZeroToTwoOne,     'ncs_navigator/core/mdes/version_migrations/two_zero_to_two_one'
    autoload :TwoOneToTwoTwo,      'ncs_navigator/core/mdes/version_migrations/two_one_to_two_two.rb'
    autoload :TwoTwoToThreeOne,    'ncs_navigator/core/mdes/version_migrations/two_two_to_three_one'
    autoload :ThreeZeroToThreeTwo, 'ncs_navigator/core/mdes/version_migrations/three_zero_to_three_two'
  end
end
