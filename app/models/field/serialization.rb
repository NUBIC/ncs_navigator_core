module Field
  ##
  # JSON serialization for {Fieldwork}.
  #
  # FIXME: This should probably be a set of ActiveModel::Serializers.
  module Serialization
    include Adoption

    def as_json(options = nil)
      map_instruments_to_plans

      {
        'contacts' => contacts_as_json(options),
        'event_templates' => event_templates_as_json(options),
        'instrument_plans' => instrument_plans_as_json(options),
        'participants' => participants_as_json(options)
      }
    end

    ##
    # @private
    def contacts_as_json(options)
      contacts.map do |c|
        mc = m c
        mp = m c.person

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
        me = m e

        if me
          adapt_model(me).as_json(options).merge({
            'instruments' => instruments_as_json(e, person, options),
            'name' => me.event_type.to_s,
            'p_id' => me.participant.public_id,
            'version' => me.updated_at.utc
          })
        end
      end.compact
    end

    ##
    # @private
    def instruments_as_json(event, person, options)
      instruments.select { |i| i.event == event && i.person == person }.map do |i|
        mi = m i
        plan = plan_for(i)

        if mi && plan
          adapt_model(mi).as_json(options).merge({
            'instrument_plan_id' => plan.id,
            'name' => i.name,
            'response_sets' => mi.response_sets
          })
        end
      end.compact
    end

    ##
    # @private
    def instrument_plans_as_json(options)
      instrument_plans.map do |p|
        { 'instrument_plan_id' => p.id,
          'instrument_templates' => instrument_templates_as_json(p, options)
        }
      end
    end

    ##
    # @private
    def event_templates_as_json(options)
      codes = NcsCode.for_attributes('instrument_type_code', 'event_type_code').
        table(:display_text)

      event_codes = codes['EVENT_TYPE_CL1']

      event_templates.map do |et|
        l = EventLabel.new(et.event.label.content)

        { 'event_type_code' => l.ncs_code(event_codes).local_code,
          'name' => l.display_text,
          'instruments' => event_template_instruments_as_json(et.instruments, options),
          'response_templates' => event_template_responses_as_json(et.response_templates, options)
        }
      end
    end

    ##
    # @private
    def event_template_instruments_as_json(instruments, options)
      instruments.each_with_object([]) do |i, result|
        plan = plan_for(i)
        l = InstrumentLabel.new(i.survey.access_code)
        code = l.ncs_code

        if plan && code
          result << {
            'instrument_plan_id' => plan.id,
            'instrument_type_code' => code.local_code,
            'instrument_version' => l.mdes_version,
            'name' => i.name
          }
        else
          if !plan
            logger.warn "Plan for instrument <#{l.content}> could not be found"
          end

          if !code
            logger.warn "NcsCode for instrument <#{l.content}> could not be found"
          end
        end
      end
    end

    ##
    # @private
    def event_template_responses_as_json(templates, options)
      templates.map do |t|
        { 'aref' => t.aref,
          'qref' => t.qref,
          'survey_id' => t.survey_id,
          'value' => t.value
        }
      end
    end

    ##
    # @private
    def instrument_templates_as_json(plan, options)
      plan.surveys.map do |s|
        ms = m s

        if ms
          {
            'instrument_template_id' => ms.api_id,
            'participant_type' => s.participant_type.try(:content),
            'survey' => ms,
            'version' => ms.updated_at.utc
          }
        end
      end.compact
    end

    ##
    # @private
    def map_instruments_to_plans
      @plan_map = {}.tap do |h|
        instrument_plans.each { |p| h[p.root] = p }
      end
    end

    ##
    # @private
    def plan_for(instrument)
      @plan_map[instrument]
    end

    ##
    # @private
    def participants_as_json(options)
      participants = {}

      people.each do |p|
        pm = m p
        participant = pm.try(:participant)

        next unless participant && pm

        if participants.has_key?(participant)
          participants[participant] << pm
        else
          participants[participant] = [pm]
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

      { 'first_name' => person.first_name,
        'last_name' => person.last_name,
        'middle_name' => person.middle_name,
        'prefix_code' => person.prefix_code,
        'suffix_code' => person.suffix_code,
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

    ##
    # @private
    class InstrumentLabel
      extend Forwardable

      def_delegators :@label, :mdes_version, :content

      def initialize(label)
        @label = label
      end

      ##
      # Retrieving the type code for an instrument label is kind of evil.  At
      # present, the following procedure is required:
      #
      # 1. interpret the instrument label as an access code
      # 2. find the latest survey for the access code
      # 3. find the NCS instrument type code whose display text matches the
      #    survey's title
      def ncs_code
        if s = Survey.most_recent_for_access_code(content)
          NcsCode.for_list_name_and_local_code('INSTRUMENT_TYPE_CL1', s.instrument_type)
        end
      end
    end
  end
end
