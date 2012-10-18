module Field::Adapters
  module ResponseSet
    class ModelAdapter
      include Field::Adapter
      include Field::Adapters::Model

      attr_accessors [
        'completed_at',
        { 'uuid' => 'api_id' }
      ]

      def pending_prerequisites
        return {} unless source

        { ::Instrument => [source.ancestors[:instrument].try(:[], :instrument_id)],
          ::Participant => [source.p_id],
          ::Survey => [source.survey_id]
        }
      end
    end

    class HashAdapter
      include Field::Adapter
      include Field::Adapters::Hash

      attr_accessors %w(
        completed_at
        p_id
        instrument_id
        survey_id
        uuid
      )

      def model_class
        ::ResponseSet
      end
    end
  end
end
