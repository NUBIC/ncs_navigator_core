require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes::VersionMigrations
  class TwoTwoToThreeOne < Basic
    def initialize(options={})
      super('2.2', '3.1', options)
    end
  end
end
