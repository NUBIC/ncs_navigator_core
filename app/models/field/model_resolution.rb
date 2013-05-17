require 'ostruct'
require 'set'

module Field
  ##
  # Resolves entities derived by {Psc::ModelDerivation#derive_models} to
  # entities in Cases' database.
  #
  # For contacts and instruments that do not yet exist in Cases, builds those
  # entities via #{Contact.start} and #{Instrument.start}.
  module ModelResolution
    PERSON_EAGER_LOADING = [
      # ::Contact.start
      :contacts,

      # Event resolution
      { :participant_person_links => { :participant => [ :events ] } }
    ]

    ##
    # Maps implied objects (i.e. Psc::ImpliedEntities::*) to entities from
    # Cases' database.
    def resolutions
      @resolutions ||= {}
    end

    ##
    # Intermediate instruments generated when impied instruments 
    # (i.e. Psc::ImpliedEntities::Instrument) are resolved to entities from the 
    # Cases' database.
    def intermediate_instruments
      @intermediate_instruments ||= {}
    end

    ##
    # Finds or builds model objects.
    #
    # Resolution and construction of contact links requires a staff ID, so
    # #staff_id must be set before invoking this method.
    def reify_models
      raise 'Model resolution requires #staff_id to be set' unless staff_id

      resolutions.clear
      intermediate_instruments.clear

      logger.info 'Resolution started'

      resolve_people
      resolve_events
      resolve_contacts
      resolve_surveys
      resolve_instruments
      resolve_contact_links

      logger.info 'Resolution complete'
    end

    ##
    # Saves all generated models in a transaction; rolls back the transaction
    # if any save fails.
    #
    # Returns true if all models were saved, false otherwise.
    def save_models
      contacts = []
      instruments = []
      contact_links = []

      resolutions.values.each do |v|
        case v
        when ::Contact; contacts << v
        when ::Instrument; instruments << v
        when ::ContactLink; contact_links << v
        end
      end

      ActiveRecord::Base.transaction do
        (contacts.all?(&:save) and
         instruments.all?(&:save) and
         resolve_prereq_contact_link_associations(contact_links) and
         contact_links.all?(&:save)).tap do |ok|
           raise ActiveRecord::Rollback unless ok
         end
      end
    end

    ##
    # Shorthand to look up a model for an implication object.
    def m(implied)
      resolutions[implied]
    end

    ##
    # FIXME: This is a bit of a mess.
    #
    # EntityResolution builds ContactLinks with references to other model
    # objects.  At association time, these model objects may not be persisted.
    #
    # Here's what the problem looks like:
    #
    #     c = Contact.new
    #     i = Instrument.new
    #     cl = ContactLink.new(:contact => c, :instrument => i)
    #
    #     c.save # => true
    #     i.save # => true
    #     cl.save
    #
    # When we execute cl.save, the IDs of c and i will be copied to their
    # foreign key fields *after* validations have run.  Presence validations
    # interfere with this:
    #
    #     class ContactLink < ActiveRecord::Base
    #       validates_presence_of :contact_id
    #     end
    #
    #     cl = ContactLink.new(:contact => c, :instrument => i)
    #     c.save # => true
    #     cl.save # => false, whoops
    #
    # This method addresses this problem by re-reading ContactLink
    # prerequisites.
    #
    # A Real Fix for this would be to derive contact links only after we can
    # ensure that we will no longer be creating contacts, but that's a much
    # bigger problem to tackle.
    #
    # @private
    def resolve_prereq_contact_link_associations(links)
      links.each do |l|
        resolve_prereq_contact_link_association(l, :contact)
      end
    end

    ##
    # @private
    def resolve_prereq_contact_link_association(link, name)
      assoc = link.association(name)

      if assoc.loaded? && link.send(assoc.reflection.foreign_key).blank?
        assoc.replace(assoc.target)
      end
    end

    ##
    # @private
    def resolve_people
      ptable = index(:person_id => people)
      found = ::Person.where(:person_id => ptable.keys).includes(PERSON_EAGER_LOADING)
      ftable = index(:person_id => found)

      ptable.each do |person_id, person|
        model = ftable[person_id]

        if !model
          logger.error "Cannot map {person ID = #{person_id}} to a person"
        end

        resolutions[person] = ftable[person_id]
      end
    end

    ##
    # @private
    def resolve_events
      events.each do |event|
        participant = m(event.person).try(:participant)

        next if !participant

        possible = participant.events
        code = event.label.content
        expected = OpenStruct.new(:labels => "event:#{code}", :ideal_date => event.ideal_date)
        accepted = possible.detect { |e| e.matches_activity(expected) }

        if accepted
          resolutions[event] = accepted
        else
          logger.error %Q{Cannot map {event label = #{code}, ideal date = #{event.ideal_date}, participant = #{participant.p_id}} to an event}
        end
      end
    end

    ##
    # @private
    def resolve_contacts
      contacts.each do |contact|
        p_model = m contact.person

        next if !p_model

        date = Date.parse(contact.scheduled_date)

        possible = p_model.contact_links.select { |cl| cl.staff_id == staff_id }.map(&:contact)
        accepted = possible.detect { |c| c.open? && c.contact_date_date == date }

        resolutions[contact] = accepted || ::Contact.start(p_model, :contact_date => contact.scheduled_date)
      end
    end

    ##
    # @private
    def resolve_contact_links
      contact_links.each do |link|
        pm = m link.person

        next if !pm

        cm = m link.contact
        em = m link.event
        im = m link.instrument

        accepted = pm.contact_links.detect do |cl|
          cl.staff_id == staff_id &&
            cl.person_id == pm.id &&
            cl.contact_id == cm.id &&
            cl.event_id == em.try(:id) &&
            cl.instrument_id == im.try(&:id)
        end

        resolutions[link] = accepted || ::ContactLink.new(:contact => cm, :event => em, :instrument => im, :person => pm, :staff_id => staff_id)
      end
    end

    ##
    # TODO: eliminate n-query behavior
    #
    # @private
    def resolve_instruments
      generate_intermediate_instruments

      intermediate_instruments.each do |derived, intermediates|
        intermediates.each do |intermediate|
          pm  = intermediate.respondent
          pam = intermediate.concerning
          sm  = intermediate.survey
          rm  = intermediate.referenced_survey
          em  = intermediate.event

          if pm && pam && (sm || rm) && em
            existing = resolutions[derived]
            if !existing
              resolutions[derived] = ::Instrument.start(pm, pam, rm, sm, em)
            else
              resolutions[derived] = pm.start_instrument(sm, pam, nil, em, existing)
            end
          end
        end
      end
    end

    ###
    # Builds a hash with the key the derived instrument
    # and the value is an array of instrument data needed
    # to start an instrument via ::Instrument#start
    def generate_intermediate_instruments
      instrument_plans.each do |instrument_plan|
        instrument = instrument_plan.root
        pm  = m instrument.person
        em  = m instrument.event

        instrument_plan.surveys.each do |survey|
          sm  = m survey
          rm  = m instrument.referenced_survey

          participant_type = survey.participant_type.try(:content)
          pams = [].tap do |c|
            case participant_type
            when nil, 'mother'
              c << m(instrument.person).try(:participant)
            when 'child'
              c.push(*pm.children.map(&:participant))
              if pm.children.empty?
                c << pm.participant.build_child_person_and_participant if pm.participant
              end
            else
              raise "Cannot resolve participant type '#{participant_type}'' for survey '#{sm.title}'"
            end
          end

          pams.each do |pam|
            intermediate_instruments[instrument] ||= []

            i = OpenStruct.new(
              :respondent => pm, 
              :concerning => pam, 
              :survey => sm, 
              :referenced_survey => rm, 
              :event => em)              

            intermediate_instruments[instrument] << i
          end
        end  
      end
    end

    ##
    # TODO: eliminate n-query behavior
    #
    # @private
    def resolve_surveys
      surveys.each do |survey|
        access_code = survey.access_code.content
        resolutions[survey] = ::Survey.most_recent_for_access_code(access_code)

        if !resolutions[survey]
          logger.error %Q{Cannot map {access code = #{access_code}} to a survey}
        end
      end
    end

    ##
    # @private
    def index(mapping)
      by = mapping.first.first
      entities = mapping.first.last

      Hash[*entities.map { |e| [e.send(by), e] }.flatten]
    end
  end
end
