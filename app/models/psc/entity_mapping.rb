require 'set'

class Psc::ScheduledActivityReport
  module EntityMapping
    attr_accessor :contacts
    attr_accessor :contact_links
    attr_accessor :events
    attr_accessor :instruments
    attr_accessor :people

    def process
      self.contacts = Set.new
      self.contact_links = Set.new
      self.events = Set.new
      self.instruments = Set.new
      self.people = Set.new

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
      p = Person.new(row['subject']['person_id'])
      people << p
      p
    end

    ##
    # @private
    def add_contact(row, person)
      c = Contact.new(row['scheduled_date'], person)
      contacts << c
      c
    end

    ##
    # @private
    def add_event(row, contact, person)
      el = row['labels'].detect { |r| r.starts_with?('event:') }

      if el
        e = Event.new(el, row['ideal_date'], contact, person)
        events << e
        e
      end
    end

    ##
    # @private
    def add_instrument(row, event, person)
      il = row['labels'].detect { |r| r.starts_with?('instrument:') }

      if il
        i = Instrument.new(il, row['activity_name'], event, person)
        instruments << i
        i
      end
    end

    ##
    # @private
    def add_contact_link(person, contact, event, instrument)
      cl = EM::ContactLink.new(person, contact, event, instrument)
      contact_links << cl
      cl
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
