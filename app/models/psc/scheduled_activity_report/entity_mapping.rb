require 'ostruct'
require 'set'

class Psc::ScheduledActivityReport
  module EntityMapping
    attr_reader :contact_links
    attr_reader :contacts
    attr_reader :events
    attr_reader :instruments
    attr_reader :people
    attr_reader :surveys

    def process
      @contacts = Collection.new(self)
      @contact_links = Collection.new(self)
      @events = EventCollection.new(self)
      @instruments = InstrumentCollection.new(self)
      @people = PersonCollection.new(self)
      @surveys = SurveyCollection.new(self)

      rows.each do |row|
        p = add_person(row)
        c = add_contact(row, p)
        e = add_event(row, c, p)
        s = add_survey(row)
        i = add_instrument(row, s, e, p) if s && e

        add_contact_link(p, c, e, i)
      end
    end

    ##
    # Finds or builds model objects that correspond to the entities derived by
    # #process.
    def resolve_models
      cache = Cache.new

      [ people,
        events,
        surveys,
        instruments
      ].each { |c| c.resolve_models(cache) }
    end

    ##
    # @private
    def add_person(row)
      people << Person.new(row['subject']['person_id'])
    end

    ##
    # @private
    def add_contact(row, person)
      contacts << Contact.new(row['scheduled_date'], person)
    end

    ##
    # @private
    def add_event(row, contact, person)
      el = row['labels'].detect { |r| r.starts_with?('event:') }

      events << Event.new(el, row['ideal_date'], contact, person) if el
    end

    ##
    # @private
    def add_instrument(row, survey, event, person)
      instruments << Instrument.new(survey, row['activity_name'], event, person)
    end

    ##
    # @private
    def add_survey(row)
      il = row['labels'].detect { |r| r.starts_with?('instrument:') }

      surveys << Survey.new(il) if il
    end

    ##
    # @private
    def add_contact_link(person, contact, event, instrument)
      contact_links << ContactLink.new(person, contact, event, instrument)
    end

    class Collection
      include Enumerable

      attr_reader :host

      def initialize(host)
        @set = {}
        @host = host
      end

      ##
      # Given two value objects v1 and v2 that are equal but not eq, selects
      # the first of [v1, v2] added to the collection, and returns it for all
      # subsequent << operations.
      #
      # We do this because mutating non-comparable state on value objects is
      # quite convenient when it comes to model resolution.
      def <<(item)
        if @set.has_key?(item)
          @set[item]
        else
          @set[item] = item
        end

        @set[item]
      end

      def each
        @set.values.each { |v| yield v }
      end

      ##
      # For testing.
      def ==(other)
        Set.new(@set.values) == Set.new(other)
      end

      ##
      # Also for testing.
      def models
        Set.new(map(&:model))
      end

      def logger
        @host.logger
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

    class PersonCollection < Collection
      ASSOCIATIONS = {
        :participant_person_links => {
          :participant => [
            {
              :events => [
                :instruments, :contacts
              ],
            },
            {
              :people => [
                { :addresses => :state },
                :telephones,
                :emails
              ]
            }
          ]
        }
      }

      def resolve_models(cache)
        ids = map(&:person_id)
        found = index ::Person.where(:person_id => ids).includes(ASSOCIATIONS)

        each do |p|
          p.model = found[p.person_id]

          if !p.model
            logger.error "Cannot map {person ID = #{p.person_id}} to a person"
          end
        end

        cache.add_people(found)
      end

      def index(people)
        {}.tap do |h|
          people.each { |p| h[p.person_id] = p }
        end
      end
    end

    class EventCollection < Collection
      def resolve_models(cache)
        each { |e| resolve_model(e, cache) }
      end

      def resolve_model(event, cache)
        participant = cache.participant_for(event.person)

        if !participant
          return
        end

        possible = participant.events
        expected = OpenStruct.new(:labels => event.label, :ideal_date => event.ideal_date)
        accepted = possible.detect { |event| event.matches_activity(expected) }

        if accepted
          event.model = accepted
        else
          logger.error %Q{Cannot map {label = #{event.label}, ideal date = #{event.ideal_date}, participant = #{participant.p_id}} to an event}
        end
      end
    end

    class SurveyCollection < Collection
      # TODO: eliminate n-query behavior
      def resolve_models(cache)
        each do |survey|
          survey.model = ::Survey.most_recent_for_access_code(survey.access_code)

          if !survey.model
            logger.error %Q{Cannot map {access code = #{survey.access_code}} to a survey}
          end
        end
      end
    end

    class InstrumentCollection < Collection
      def resolve_models(cache)
        each do |instrument|
          args = [instrument.person, instrument.survey, instrument.event].map(&:model)

          instrument.model = ::Instrument.start(*args) if args.all?
        end
      end
    end

    module HasModel
      attr_accessor :model

      def resolved?
        model
      end
    end

    class Contact < Struct.new(:scheduled_date, :person)
      include HasModel
    end

    class ContactLink < Struct.new(:person, :contact, :event, :instrument)
      include HasModel
    end

    class Event < Struct.new(:label, :ideal_date, :contact, :person)
      include HasModel
    end

    class Instrument < Struct.new(:survey, :name, :event, :person)
      include HasModel
    end

    class Person < Struct.new(:person_id)
      include HasModel
    end

    class Survey < Struct.new(:instrument_label)
      include HasModel

      def access_code
        instrument_label.match(/^instrument:(.+)_v[\d\.]+/i)[1]
      end
    end
  end
end
