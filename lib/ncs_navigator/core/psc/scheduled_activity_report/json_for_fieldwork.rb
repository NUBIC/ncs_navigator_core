# encoding: utf-8

require 'ncs_navigator/core'
require 'rabl'

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
              'response_set' => JSON.parse(r.instrument.response_set.to_json),
              'version' => r.instrument.updated_at.utc
            }
          end
        end

        events = [].tap do |a|
          if r.event
            a << {
              'disposition' => r.event.event_disposition,
              'disposition_category' => r.event.event_disposition_category_code,
              'end_date' => r.event.event_end_date,
              'end_time' => r.event.event_end_time,
              'event_id' => r.event.event_id,
              'instruments' => instruments,
              'name' => r.event.event_type.to_s,
              'start_date' => r.event.event_start_date,
              'start_time' => r.event.event_start_time,
              'version' => r.event.updated_at.utc
            }
          end
        end

        {
          'contact_date' => c.contact_date,
          'contact_id' => c.contact_id,
          'disposition' => c.contact_disposition,
          'end_time' => c.contact_end_time,
          'events' => events,
          'person_id' => r.person.person_id,
          'start_time' => c.contact_start_time,
          'type' => c.contact_type_code,
          'version' => c.updated_at.utc
        }
      end
    end

    def participants_as_json
      address_hash = lambda do |addr|
        return {} unless addr

        {
          'city' => addr.city,
          'state' => addr.state.display_text,
          'street' => [addr.address_one, addr.address_two].join("\n"),
          'zip_code' => [addr.zip, addr.zip4].join('-')
        }
      end

      rows.map(&:participant).compact.uniq.map do |pa|
        {}.tap do |h|
          persons = pa.participant_person_links.map do |l|
            person = l.person
            {
              'cell_phone' => person.primary_cell_phone.try(:phone_nbr),
              'email' => person.primary_email.try(:email),
              'home_phone' => person.primary_home_phone.try(:phone_nbr),
              'name' => person.name,
              'person_id' => person.person_id,
              'relationship_code' => l.relationship_code.to_i,
              'version' => person.updated_at.utc
            }.merge(address_hash[person.primary_address])
          end

          h['p_id'] = pa.p_id
          h['persons'] = persons
          h['version'] = pa.updated_at.utc
        end
      end
    end

    def instrument_templates_as_json
      rows.map(&:survey).compact.uniq.map do |s|
        {
          'instrument_template_id' => s.api_id,
          'survey' => JSON.parse(s.to_json),
          'version' => s.updated_at.utc
        }
      end
    end
  end
end