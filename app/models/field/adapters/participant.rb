module Field::Adapters
  module Participant
    ATTRIBUTES = %w(
      p_id
    )

    class HashAdapter < Field::HashAdapter
      attr_accessors ATTRIBUTES

      def model_class
        ::Participant
      end
    end

    class ModelAdapter < Field::ModelAdapter
      attr_accessors ATTRIBUTES
    end
  end
end
