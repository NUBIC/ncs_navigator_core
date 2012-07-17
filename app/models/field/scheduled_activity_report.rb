require 'ncs_navigator/core'

module Field
  class ScheduledActivityReport < ::Psc::ScheduledActivityReport
    include ::Psc::ScheduledActivityReport::EntityResolution
    include NcsNavigator::Core::Fieldwork::Adapters

    def as_json(options = nil)
      {
        'contacts' => contacts_as_json(options),
        'instrument_templates' => instrument_templates_as_json(options),
        'participants' => participants_as_json(options)
      }
    end

    ##
    # @private
    def contacts_as_json(options)
      contacts.map do |c|
        mc = c.model
        mp = c.person.model

        if mc && mp
          adapt_model(mc).as_json(options).merge({
            'events' => events_as_json(c, c.person, options),
            'person_id' => mp.person_id,
            'version' => mc.updated_at.utc
          })
        end
      end.compact
    end

    ##
    # @private
    def events_as_json(contact, person, options)
      events.select { |e| e.contact == contact && e.person == person }.map do |e|
        m = e.model

        if m
          adapt_model(m).as_json(options).merge({
            'name' => m.event_type.to_s,
            'instruments' => instruments_as_json(e, person, options),
            'version' => m.updated_at.utc
          })
        end
      end.compact
    end

    ##
    # @private
    def instruments_as_json(event, person, options)
      instruments.select { |i| i.event == event && i.person == person }.map do |i|
        mi = i.model
        ms = i.survey.model

        if mi && ms
          adapt_model(mi).as_json(options).merge({
            'instrument_template_id' => ms.api_id,
            'name' => ms.title,
            'response_set' => mi.response_set
          })
        end
      end.compact
    end

    ##
    # @private
    def instrument_templates_as_json(options)
      surveys.map do |s|
        m = s.model

        if m
          {
            'instrument_template_id' => m.api_id,
            'survey' => m,
            'version' => m.updated_at.utc
          }
        end
      end.compact
    end

    ##
    # @private
    def participants_as_json(options)
      participants = {}

      people.each do |p|
        participant = p.participant_model

        next unless participant && p.model

        if participants.has_key?(participant)
          participants[participant] << p.model
        else
          participants[participant] = [p.model]
        end
      end

      participants.map do |pa, ps|
        { 'p_id' => pa.p_id,
          'version' => pa.updated_at.utc,
          'persons' => ps.map { |p| person_as_json(p, pa, options) }
        }
      end
    end

    ##
    # @private
    def person_as_json(person, participant, options)
      link = participant.participant_person_links.detect { |p| p.person_id == person.id }
      addr = person.primary_address

      { 'name' => person.name,
        'person_id' => person.person_id,
        'relationship_code' => link.relationship_code.to_i,
        'cell_phone' => person.primary_cell_phone.try(:phone_nbr),
        'email' => person.primary_email.try(:email),
        'home_phone' => person.primary_home_phone.try(:phone_nbr),
        'version' => person.updated_at.utc
      }.merge(address_as_json(addr, options))
    end

    ##
    # @private
    def address_as_json(address, options)
      return {} unless address

      { 'city' => address.city,
        'state' => address.state.try(:display_text),
        'street' => [address.address_one, address.address_two].join("\n"),
        'zip_code' => [address.zip, address.zip4].join('-')
      }
    end
  end
end
