module Field::Adapters
  module Person
    ATTRIBUTES = %w(
      first_name
      last_name
      middle_name
      person_id
      prefix_code
      suffix_code
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
        ::Person
      end
    end
  end
end
