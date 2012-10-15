module Field::Adapters
  module Participant
    ATTRIBUTES = %w(
      p_id
    )

    class ModelAdapter
      include Field::Adapter
      include Field::Adapters::Model

      attr_accessors ATTRIBUTES
    end

    class HashAdapter
      include Field::Adapter
      include Field::Adapters::Hash

      attr_accessors ATTRIBUTES

      def model_class
        ::Participant
      end
    end
  end
end
