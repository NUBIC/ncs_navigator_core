module Field::Adapters
  module Response
    class HashAdapter < Field::HashAdapter
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

      def response_set_public_id
        ancestors[:response_set].uuid
      end

      def model_class
        ::Response
      end
    end

    class ModelAdapter < Field::ModelAdapter
      include SetsPrerequisites

      attr_accessors [
        { 'uuid' => 'api_id' },
        'response_group',
        'value'
      ]

      def answer_public_id
        source.try(:answer_public_id) || target.answer.try(:api_id)
      end

      def question_public_id
        source.try(:question_public_id) || target.question.try(:api_id)
      end

      def response_set_public_id
        source.try(:ancestors).try(:[], :response_set).try(:uuid) ||
          target.response_set.try(:api_id)
      end

      def pending_prerequisites
        return {} unless source

        { ::Answer => [answer_public_id],
          ::Question => [question_public_id],
          ::ResponseSet => [response_set_public_id]
        }
      end

      def ensure_prerequisites(map)
        try_to_set(map, :answer, :question, :response_set)
      end
    end
  end
end
