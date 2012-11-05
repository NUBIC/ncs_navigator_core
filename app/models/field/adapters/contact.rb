# == Schema Information
#
# Table name: contacts
#
#  contact_comment         :text
#  contact_date            :string(10)
#  contact_date_date       :date
#  contact_disposition     :integer
#  contact_distance        :decimal(6, 2)
#  contact_end_time        :string(255)
#  contact_id              :string(36)       not null
#  contact_interpret_code  :integer          not null
#  contact_interpret_other :string(255)
#  contact_language_code   :integer          not null
#  contact_language_other  :string(255)
#  contact_location_code   :integer          not null
#  contact_location_other  :string(255)
#  contact_private_code    :integer          not null
#  contact_private_detail  :string(255)
#  contact_start_time      :string(255)
#  contact_type_code       :integer          not null
#  contact_type_other      :string(255)
#  created_at              :datetime
#  id                      :integer          not null, primary key
#  lock_version            :integer          default(0)
#  psu_code                :integer          not null
#  transaction_type        :string(255)
#  updated_at              :datetime
#  who_contacted_code      :integer          not null
#  who_contacted_other     :string(255)
#

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
