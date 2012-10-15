module Field::Adapters
  module ResponseSet
    ATTRIBUTES = %w(
      completed_at
      created_at
      p_id
      instrument_id
      survey_id
      uuid
    )

    class ModelAdapter
      include Field::Adapter
      include Field::Adapters::Model

      attr_accessors ATTRIBUTES
      attr_accessors [
        { 'uuid' => 'api_id' }
      ]

      def survey_id
        target.survey.try(:api_id)
      end

      def survey_id=(val)
        target.survey_id = ::Survey.where(:api_id => val).first.try(:id)
      end

      attr_accessible :survey_id

      def p_id
        target.participant.try(:public_id)
      end

      def p_id=(val)
        target.participant_id = ::Participant.where(:p_id => val).first.try(:id)
      end

      attr_accessible :p_id

      def instrument_id
        target.instrument.try(:instrument_id)
      end

      def instrument_id=(val)
        target.instrument_id = ::Instrument.where(:instrument_id => val).first.try(:id)
      end

      attr_accessible :instrument_id
    end

    class HashAdapter
      include Field::Adapter
      include Field::Adapters::Hash

      attr_accessors ATTRIBUTES

      def model_class
        ::ResponseSet
      end

      def to_model
        super.tap do |m|
          m.instrument_id = ancestors[:instrument].try(:instrument_id)
        end
      end
    end
  end
end
