module Field::Adapters
  ##
  # Both {Event::ModelAdapter} and {Instrument::ModelAdapter} construct
  # {ContactLink} model objects as postrequisites.  This module contains code
  # that does that.
  #
  # @private
  module ContactLinkConstruction
    def staff_id
      superposition.try(:staff_id)
    end

    def pending_postrequisites
      return {} unless source

      {
        ::Contact => [a('contact_public_id')],
        ::Event => [a('event_public_id')],
        ::Person => [a('person_public_id')],
        ::Instrument => [a('instrument_public_id')]
      }.reject { |_, v| v.blank? }
    end

    def ensure_postrequisites(map)
      return true unless source

      parameters = {
        :contact_id => map.id_for(::Contact, a('contact_public_id')),
        :event_id => map.id_for(::Event, a('event_public_id')),
        :person_id => map.id_for(::Person, a('person_public_id')),
        :instrument_id => map.id_for(::Instrument, a('instrument_public_id'))
      }.reject { |_, v| v.blank? }

      ContactLink.exists?(parameters) or
        ContactLink.create(parameters.merge(:staff_id => staff_id)).persisted?
    end

    module_function

    def a(attr)
      send(attr) if respond_to?(attr)
    end
  end
end
