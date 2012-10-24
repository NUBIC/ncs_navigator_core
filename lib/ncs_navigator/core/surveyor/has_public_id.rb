require 'ncs_navigator/core'

module NcsNavigator::Core::Surveyor
  ##
  # A convenience around {NcsNavigator::Core::HasPublicId} for Surveyor
  # models.
  module HasPublicId
    extend ActiveSupport::Concern

    included do
      include NcsNavigator::Core::HasPublicId
    end

    def public_id
      api_id
    end

    module ClassMethods
      def public_id_field
        :api_id
      end
    end
  end
end
