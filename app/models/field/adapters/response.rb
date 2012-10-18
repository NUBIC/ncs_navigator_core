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

      def answer_public_id
        source.try(:answer_public_id) || target.answer.try(&:api_id)
      end

      def question_public_id
        source.try(:question_public_id) || target.question.try(&:api_id)
      end

      def pending_prerequisites
        return {} unless source

        { ::Answer => [source.answer_id],
          ::Question => [source.question_id],
          ::ResponseSet => [source.ancestors[:response_set].try(:uuid)]
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

      alias_method :answer_public_id, :answer_id
      alias_method :question_public_id, :question_id

      def model_class
        ::Response
      end
    end
  end
end
