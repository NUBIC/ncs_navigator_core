class EventReportRowSerializer < ActiveModel::Serializer
  has_one :event_type
  attributes :event_id, :scheduled_date
  attributes :participant_id, :participant_first_name, :participant_last_name
  attribute :data_collectors, :key => :data_collector_usernames

  def participant_id
    object.participant.try(:p_id)
  end

  def participant_first_name
    person.try(:first_name)
  end

  def participant_last_name
    person.try(:last_name)
  end

  def attributes
    o = object

    super.tap do |h|
      h['disposition_code'] = {
        category_code: o.event_disposition_category_code,
        interim_code: o.event_disposition,
        disposition: o.disposition_code.try(:disposition)
      }

      h['links'] = []
    end
  end

  private

  def person
    object.participant.try(:person)
  end
end
