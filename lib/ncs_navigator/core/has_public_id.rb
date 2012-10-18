module NcsNavigator::Core
  ##
  # Many models in Cases expose a public ID, which is a UUID that is
  # visible to end users.
  #
  # All models in Cases also have an integral surrogate ID that is used for
  # establishing associations.
  #
  # A recurring pattern in parts of Cases (i.e. the merge code) is mapping
  # public IDs to internal IDs.  This module provides a standard interface for
  # doing that.
  #
  # Users of this module must respond to .public_id_field, #public_id, and
  # .primary_key.  ActiveRecord objects with acts_as_mdes_record set satisfy
  # this expectation.
  module HasPublicId
    extend ActiveSupport::Concern

    module ClassMethods
      def with_public_ids(ids)
        where(public_id_field => ids)
      end

      ##
      # Generates a public_id => id map.
      def public_id_to_id_map(ids)
        {}.tap do |h|
          with_public_ids(ids).select([public_id_field, primary_key]).each do |m|
            h[m.public_id] = m.id
          end
        end
      end
    end
  end
end
