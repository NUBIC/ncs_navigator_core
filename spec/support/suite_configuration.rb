require 'ncs_navigator/configuration'

module NcsNavigator::Core
  module Spec
    def self.reset_navigator_ini
      NcsNavigator.configuration =
        NcsNavigator::Configuration.new(File.expand_path('../../navigator.ini', __FILE__))
    end
  end
end
