module Field::Adapters
  module Response
    class ModelAdapter
      include Field::Adapter
      include Field::Adapters::Model

      attr_accessors [
        { 'uuid' => 'api_id' },
        'response_group',
        'value'
      ]

      def unresolved_references
        return {} unless source

        { ::Answer => source.answer_id,
          ::Question => source.question_id,
          ::ResponseSet => source.ancestors[:response_set].try(:uuid)
        }
      end
    end

    class HashAdapter
      include Field::Adapter
      include Field::Adapters::Hash

      attr_accessors %w(
        answer_id
        created_at
        question_id
        response_group
        updated_at
        uuid
        value
      )

      def model_class
        ::Response
      end
    end
  end
end
