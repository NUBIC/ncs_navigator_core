module Field::Adapters
  module Event
    ATTRIBUTES = %w(
      event_breakoff_code
      event_comment
      event_disposition
      event_disposition_category_code
      event_end_date
      event_end_time
      event_id
      event_incentive_type_code
      event_incentive_cash
      event_repeat_key
      event_start_date
      event_start_time
      event_type_code
      event_type_other
      event_type_code
      event_type_other
    )

    class HashAdapter < Field::HashAdapter
      attr_accessors ATTRIBUTES
      attr_accessors %w(
        p_id
      )

      transform :event_end_date, :to_date
      transform :event_incentive_cash, :to_bigdecimal
      transform :event_start_date, :to_date

      def model_class
        ::Event
      end
    end

    class ModelAdapter < Field::ModelAdapter
      include ContactLinkConstruction

      attr_accessors ATTRIBUTES

      def participant_public_id
        source.try(:p_id)
      end

      def contact_public_id
        source.try(:ancestors).try(:[], :contact).try(:contact_id)
      end

      def event_public_id
        event_id
      end

      def person_public_id
        source.try(:ancestors).try(:[], :contact).try(:person_id)
      end

      def pending_prerequisites
        return {} unless source

        { ::Participant => [participant_public_id] }
      end

      def ensure_prerequisites(map)
        return true unless source

        participant_id = map.id_for(::Participant, participant_public_id)
        target.participant_id = participant_id
      end
    end
  end
end
