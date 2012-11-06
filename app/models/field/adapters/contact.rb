module Field::Adapters
  module Contact
    ATTRIBUTES = %w(
      contact_comment
      contact_date_date
      contact_id
      contact_disposition
      contact_distance
      contact_end_time
      contact_interpret_code
      contact_interpret_other
      contact_language_code
      contact_language_other
      contact_location_code
      contact_location_other
      contact_private_code
      contact_private_detail
      contact_start_time
      contact_type_code
      who_contacted_code
      who_contacted_other
    )

    class HashAdapter < Field::HashAdapter
      attr_accessors ATTRIBUTES

      transform :contact_date_date, :to_date
      transform :contact_distance, :to_bigdecimal

      def model_class
        ::Contact
      end

      ##
      # Used by {Instrument::ModelAdapter} to construct {ContactLink}s.
      def person_id
        get('person_id')
      end
    end

    class ModelAdapter < Field::ModelAdapter
      attr_accessors ATTRIBUTES
    end
  end
end
