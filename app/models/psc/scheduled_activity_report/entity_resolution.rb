require 'ostruct'
require 'set'

class Psc::ScheduledActivityReport
  ##
  # Resolves entities implied by the PSC scheduled activity report to entities
  # in Cases' database.
  #
  # For contacts and instruments that do not yet exist in Cases, builds those
  # entities via #{Contact.start} and #{Instrument.start}.
  module EntityResolution
    attr_accessor :staff_id

    PERSON_EAGER_LOADING = [
      # ::Contact.start
      :contacts,

      # Event resolution
      { :participant_person_links => { :participant => { :events => :event_type } } }
    ]

    ##
    # Finds or builds model objects that correspond to the entities derived by
    # #process.
    #
    # Resolution and construction of contact links requires a staff ID, so
    # #staff_id must be set before invoking this method.
    def process
      raise 'Model resolution requires #staff_id to be set' unless staff_id

      super

      cache = Cache.new

      resolve_people(cache)
      resolve_events
      resolve_contacts
      resolve_surveys
      resolve_instruments
      resolve_contact_links
    end

    ##
    # Saves all generated models in a transaction; rolls back the transaction
    # if any save fails.
    #
    # Returns true if all models were saved, false otherwise.
    def save_models
      ActiveRecord::Base.transaction do
        [contacts, instruments, contact_links].all? do |c|
          c.map(&:model).compact.all?(&:save)
        end.tap do |ok|
          raise ActiveRecord::Rollback unless ok
        end
      end
    end

    ##
    # @private
    def resolve_contacts
      contacts.each do |contact|
        p_model = contact.person.model

        next if !p_model

        date = Date.parse(contact.scheduled_date)

        possible = p_model.contact_links.select { |cl| cl.staff_id == staff_id }.map(&:contact)
        accepted = possible.detect { |c| c.contact_date_date == date }

        contact.model = accepted || ::Contact.start(p_model, :contact_date => contact.scheduled_date)
      end
    end

    ##
    # @private
    def resolve_contact_links
      contact_links.each do |link|
        pm = link.person.model

        next if !pm

        cm = link.contact.model
        em = link.event.try(:model)
        im = link.instrument.try(:model)

        accepted = pm.contact_links.detect do |cl|
          cl.staff_id == staff_id &&
            cl.person_id == pm.id &&
            cl.contact_id == cm.id &&
            cl.event_id == em.try(:id) &&
            cl.instrument_id == im.try(&:id)
        end

        link.model = accepted || ::ContactLink.new(:contact => cm, :event => em, :instrument => im, :person => pm, :staff_id => staff_id)
      end
    end

    ##
    # @private
    def resolve_events
      events.each do |event|
        participant = event.person.participant_model

        next if !participant

        possible = participant.events
        expected = OpenStruct.new(:labels => event.label, :ideal_date => event.ideal_date)
        accepted = possible.detect { |e| e.matches_activity(expected) }

        if accepted
          event.model = accepted
        else
          logger.error %Q{Cannot map {label = #{event.label}, ideal date = #{event.ideal_date}, participant = #{participant.p_id}} to an event}
        end
      end
    end

    ##
    # TODO: eliminate n-query behavior
    #
    # @private
    def resolve_instruments
      instruments.each do |instrument|
        pm  = instrument.person.model
        pam = instrument.person.participant_model
        sm  = instrument.survey.model
        rm  = instrument.referenced_survey.try(:model)
        em  = instrument.event.model

        if pm && pam && (sm || rm) && em
          instrument.model = ::Instrument.start(pm, pam, rm, sm, em)
        end
      end
    end

    ##
    # @private
    def resolve_people(cache)
      ids = people.map(&:person_id)
      found = index_people ::Person.where(:person_id => ids).includes(PERSON_EAGER_LOADING)

      cache.add_people(found)

      people.each do |p|
        p.model = found[p.person_id]
        p.participant_model = cache.participant_for(p)

        if !p.model
          logger.error "Cannot map {person ID = #{p.person_id}} to a person"
        end
      end
    end

    ##
    # @private
    def index_people(people)
      {}.tap do |h|
        people.each { |p| h[p.person_id] = p }
      end
    end

    ##
    # TODO: eliminate n-query behavior
    #
    # @private
    def resolve_surveys
      surveys.each do |survey|
        survey.model = ::Survey.most_recent_for_access_code(survey.access_code)

        if !survey.model
          logger.error %Q{Cannot map {access code = #{survey.access_code}} to a survey}
        end
      end
    end

    class Cache
      attr_reader :people

      def add_people(people_index)
        @people = people_index
      end

      def participant_for(person)
        @people[person.person_id].try(:participant)
      end
    end
  end
end
