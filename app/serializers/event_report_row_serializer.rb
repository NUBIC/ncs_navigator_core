class EventReportRowSerializer < ActiveModel::Serializer
  has_one :event_type
  attributes :event_id, :participant_id, :scheduled_date
  attribute :data_collectors, :key => :data_collector_usernames

  def attributes
    o = object

    super.tap do |h|
      h['disposition_code'] = {
        category_code: o.event_disposition_category_code,
        interim_code: o.event_disposition,
        disposition: o.disposition_code.disposition
      }

      h['links'] = []
    end
  end
end
