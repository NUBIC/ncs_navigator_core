module Field::Adapters
  module ResponseSet
    class HashAdapter < Field::HashAdapter
      attr_accessors %w(
        completed_at
        p_id
        person_id
        instrument_id
        survey_id
        uuid
      )

      def model_class
        ::ResponseSet
      end
    end

    class ModelAdapter < Field::ModelAdapter
      include SetsPrerequisites

      attr_accessors [
        'completed_at',
        { 'uuid' => 'api_id' }
      ]

      def pending_prerequisites
        return {} unless source

        { ::Instrument => [instrument_public_id],
          ::Participant => [participant_public_id],
          ::Person => [person_public_id],
          ::Survey => [survey_public_id]
        }
      end

      def instrument_public_id
        source.try(:ancestors).try(:[], :instrument).try(:instrument_id)
      end

      def participant_public_id
        source.try(:p_id)
      end

      def person_public_id
        source.try(:person_id)
      end

      def survey_public_id
        source.try(:survey_id)
      end

      def ensure_prerequisites(map)
        try_to_set(map, :instrument, :participant, :person, :survey)
      end
    end
  end
end
