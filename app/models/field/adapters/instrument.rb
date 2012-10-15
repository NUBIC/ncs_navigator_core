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
      supervisor_review_code
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

      transform :instrument_end_date, :to_date
      transform :instrument_start_date, :to_date

      def model_class
        ::Instrument
      end
    end
  end
end
