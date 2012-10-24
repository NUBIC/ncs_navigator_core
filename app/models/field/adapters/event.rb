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

      transform :event_end_date, :to_date
      transform :event_incentive_cash, :to_bigdecimal
      transform :event_start_date, :to_date

      def model_class
        ::Event
      end
    end

    class ModelAdapter < Field::ModelAdapter
      attr_accessors ATTRIBUTES
    end
  end
end
