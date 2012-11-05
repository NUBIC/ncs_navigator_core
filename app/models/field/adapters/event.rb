# == Schema Information
#
# Table name: events
#
#  created_at                         :datetime
#  event_breakoff_code                :integer          not null
#  event_comment                      :text
#  event_disposition                  :integer
#  event_disposition_category_code    :integer          not null
#  event_end_date                     :date
#  event_end_time                     :string(255)
#  event_id                           :string(36)       not null
#  event_incentive_cash               :decimal(12, 2)
#  event_incentive_noncash            :string(255)
#  event_incentive_type_code          :integer          not null
#  event_repeat_key                   :integer
#  event_start_date                   :date
#  event_start_time                   :string(255)
#  event_type_code                    :integer          not null
#  event_type_other                   :string(255)
#  id                                 :integer          not null, primary key
#  lock_version                       :integer          default(0)
#  participant_id                     :integer
#  psu_code                           :integer          not null
#  scheduled_study_segment_identifier :string(255)
#  transaction_type                   :string(255)
#  updated_at                         :datetime
#

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
      attr_accessors ATTRIBUTES

      def participant_public_id
        source.try(:p_id)
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
