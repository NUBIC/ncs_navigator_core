module Field::Adapters
  module Response
    class ModelAdapter
      include Field::Adapter
      include Field::Adapters::Model

      attr_accessors [
        { 'uuid' => 'api_id' },
        'response_group',
        'response_set_id',
        'value'
      ]

      def answer_id
        target.answer.try(:api_id)
      end

      def answer_id=(val)
        target.answer_id = Answer.where(:api_id => val).first.try(:id)
      end

      attr_accessible :answer_id

      def question_id
        target.question.try(:api_id)
      end

      def question_id=(val)
        target.question_id = Question.where(:api_id => val).first.try(:id)
      end

      attr_accessible :question_id
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

      ##
      # Fills in Response#response_set_id.
      def to_model
        super.tap do |m|
          m.response_set_id = ::ResponseSet.where(:api_id => ancestors[:response_set].uuid).first.try(:id)
        end
      end

      def model_class
        ::Response
      end
    end
  end
end
