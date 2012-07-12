require 'set'

class Psc::ScheduledActivityReport
  module EntityMapping
    attr_accessor :contacts
    attr_accessor :contact_links
    attr_accessor :events
    attr_accessor :instruments
    attr_accessor :people

    def process
      self.contacts = Collection.new
      self.contact_links = Collection.new
      self.events = Collection.new
      self.instruments = Collection.new
      self.people = Collection.new

      rows.each do |row|
        p = add_person(row)
        c = add_contact(row, p)
        e = add_event(row, c, p)
        i = add_instrument(row, e, p) if e
        
        add_contact_link(p, c, e, i)
      end
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
    def add_instrument(row, event, person)
      il = row['labels'].detect { |r| r.starts_with?('instrument:') }

      instruments << Instrument.new(il, row['activity_name'], event, person) if il
    end

    ##
    # @private
    def add_contact_link(person, contact, event, instrument)
      contact_links << ContactLink.new(person, contact, event, instrument)
    end

    ##
    # @private
    def add(entity, collection, *args)
      e = entity.new(*args)
      collection << e
      e
    end

    class Collection
      def initialize
        @set = Set.new
      end

      def <<(item)
        @set << item
        item
      end

      def ==(other)
        @set == other
      end
    end

    class Contact < Struct.new(:scheduled_date, :person)
    end

    class ContactLink < Struct.new(:person, :contact, :event, :instrument)
    end

    class Event < Struct.new(:label, :ideal_date, :contact, :person)
    end

    class Instrument < Struct.new(:label, :name, :event, :person)
    end

    class Person < Struct.new(:person_id)
    end
  end
end
