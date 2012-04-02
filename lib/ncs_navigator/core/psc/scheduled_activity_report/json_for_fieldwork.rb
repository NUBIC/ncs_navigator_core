require 'ncs_navigator/core'

class NcsNavigator::Core::Psc::ScheduledActivityReport
  module JsonForFieldwork
    def contacts_as_json
      rows.select(&:contact).map do |r|
        c = r.contact

        instruments = [].tap do |a|
          if r.instrument
            a << {
              'instrument_id' => r.instrument.instrument_id,
              'instrument_template_id' => r.survey.api_id,
              'name' => r.survey.title,
              'response_set' => r.instrument.response_set
            }
          end
        end

        events = [].tap do |a|
          if r.event
            a << {
              'event_id' => r.event.event_id,
              'name' => r.event.event_type.to_s,
              'instruments' => instruments
            }
          end
        end

        {
          'contact_date' => c.contact_date,
          'contact_id' => c.contact_id,
          'end_time' => c.contact_end_time,
          'start_time' => c.contact_start_time,
          'events' => events,
          'person_id' => r.person.person_id,
          'type' => c.contact_type_code
        }
      end
    end

    def participants_as_json
      rows.select(&:person).map do |r|
        {
          'p_id' => r.person.person_id
        }
      end.uniq
    end

    def instrument_templates_as_json
      rows.map(&:survey).compact.uniq
    end
  end
end
