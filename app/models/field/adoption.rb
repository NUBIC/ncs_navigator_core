module Field
  module Adoption
    def adapt_hash(type, h)
      adapter_for(type)::HashAdapter.new(h)
    end

    def adapt_model(m)
      adapter_for(m)::ModelAdapter.new(m)
    end

    def adapter_for(t)
      case t
      when :contact, ::Contact;           Field::Adapters::Contact
      when :event, ::Event;               Field::Adapters::Event
      when :instrument, ::Instrument;     Field::Adapters::Instrument
      when :participant, ::Participant;   Field::Adapters::Participant
      when :person, ::Person;             Field::Adapters::Person
      when :response, ::Response;         Field::Adapters::Response
      when :response_set, ::ResponseSet;  Field::Adapters::ResponseSet
      else raise "Cannot derive adapter type for #{t.inspect}"
      end
    end
  end
end
