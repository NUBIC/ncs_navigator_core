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
    # Maps implied objects (i.e. ScheduledActivity::Implications::*) to
    # entities from Cases' database.
    def resolutions
      @resolutions ||= {}
    end

    ##
    # Finds or builds model objects that correspond to the entities derived by
    # #process.
    #
    # Resolution and construction of contact links requires a staff ID, so
    # #staff_id must be set before invoking this method.
    def process
      raise 'Model resolution requires #staff_id to be set' unless staff_id

      super

      resolutions.clear

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
        expected = OpenStruct.new(:labels => "event:#{event.label}", :ideal_date => event.ideal_date)
        accepted = possible.detect { |e| e.matches_activity(expected) }

        if accepted
          resolutions[event] = accepted
        else
          logger.error %Q{Cannot map {event label = #{event.label}, ideal date = #{event.ideal_date}, participant = #{participant.p_id}} to an event}
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
        accepted = possible.detect { |c| c.contact_date_date == date }

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
      instruments.each do |instrument|
        pm  = m instrument.person
        pam = m(instrument.person).try(:participant)
        sm  = m instrument.survey
        rm  = m instrument.referenced_survey
        em  = m instrument.event

        if pm && pam && (sm || rm) && em
          resolutions[instrument] = ::Instrument.start(pm, pam, rm, sm, em)
        end
      end
    end

    ##
    # TODO: eliminate n-query behavior
    #
    # @private
    def resolve_surveys
      surveys.each do |survey|
        resolutions[survey] = ::Survey.most_recent_for_access_code(survey.access_code)

        if !resolutions[survey]
          logger.error %Q{Cannot map {access code = #{survey.access_code}} to a survey}
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
