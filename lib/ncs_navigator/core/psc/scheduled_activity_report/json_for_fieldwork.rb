# -*- coding: utf-8 -*-


require 'ncs_navigator/core'
require 'rabl'

class NcsNavigator::Core::Psc::ScheduledActivityReport
  module JsonForFieldwork
    include Merge
    include NcsNavigator::Core::Fieldwork::Adapters

    def contacts_as_json
      merged_rows, event_map, instrument_map = merge

      merged_rows.map do |r|
        c = r.contact

        adapt_model(c).as_json.merge({
          'events' => events_as_json(c, event_map[c.public_id], instrument_map),
          'person_id' => r.person.person_id,
          'version' => c.updated_at.utc
        })
      end
    end

    def events_as_json(contact, events, instrument_map)
      events.map do |e|
        adapt_model(e).as_json.merge({
          'instruments' => instruments_as_json(instrument_map[[contact.public_id, e.public_id]]),
          'name' => e.event_type.to_s,
          'version' => e.updated_at.utc
        })
      end
    end

    def instruments_as_json(instruments)
      instruments.map do |i|
        adapt_model(i).as_json.merge({
          'instrument_template_id' => i.survey.api_id,
          'name' => i.survey.title,
          'response_set' => JSON.parse(i.response_set.to_json)
        })
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
