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
      {}
    end

    ##
    # @private
    def participants_as_json(options)
      {}
    end
  end
end
