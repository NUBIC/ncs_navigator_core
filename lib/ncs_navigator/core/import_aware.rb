require 'ncs_navigator/core'
require 'active_support/concern'

module NcsNavigator::Core
  module ImportAware
    extend ActiveSupport::Concern

    def in_importer_mode?
      self.class.in_importer_mode?
    end

    module ClassMethods
      attr_accessor :importer_mode_on

      ##
      # Sets the importer mode to true for the duration of the provided block.
      def importer_mode
        fail "This method is intended for use with a block" unless block_given?
        original = importer_mode_on
        self.importer_mode_on = true
        result = yield
        self.importer_mode_on = original
        result
      end

      alias :in_importer_mode? :importer_mode_on
    end
  end
end
