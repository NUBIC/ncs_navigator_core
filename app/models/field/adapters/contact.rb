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

    def self.adopt_hash(h)
      HashAdapter.new(h)
    end

    def self.adopt_model(m)
      ModelAdapter.new(m)
    end

    class HashAdapter
      include Field::Adapter
      include Field::Adapters::Hash

      attr_accessors ATTRIBUTES

      transform :contact_date_date, :to_date
      transform :contact_distance, :to_bigdecimal

      def model_class
        ::Contact
      end
    end

    class ModelAdapter
      include Field::Adapter
      include Field::Adapters::Model

      attr_accessors ATTRIBUTES
    end
  end
end
