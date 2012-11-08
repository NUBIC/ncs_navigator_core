module Field::Adapters
  module Instrument
    ATTRIBUTES = %w(
      data_problem_code
      instrument_breakoff_code
      instrument_comment
      instrument_end_date
      instrument_end_time
      instrument_id
      instrument_method_code
      instrument_mode_code
      instrument_mode_other
      instrument_repeat_key
      instrument_start_date
      instrument_start_time
      instrument_status_code
      instrument_type_code
      instrument_type_other
      instrument_version
      supervisor_review_code
    )

    class HashAdapter < Field::HashAdapter
      attr_accessors ATTRIBUTES

      transform :instrument_end_date, :to_date
      transform :instrument_start_date, :to_date

      def model_class
        ::Instrument
      end
    end

    class ModelAdapter < Field::ModelAdapter
      include ContactLinkConstruction

      attr_accessors ATTRIBUTES

      def contact_public_id
        source.try(:ancestors).try(:[], :contact).try(:contact_id)
      end

      def event_public_id
        source.try(:ancestors).try(:[], :event).try(:event_id)
      end

      def instrument_public_id
        instrument_id
      end

      def person_public_id
        source.try(:ancestors).try(:[], :contact).try(:person_id)
      end
    end
  end
end
