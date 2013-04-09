# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module Field
  ##
  # A Superposition represents three states of a dataset:
  #
  # 1. original: the data as it was when the dataset was sent to Field
  # 2. proposed: the data as seen by Field
  # 3. current: the data as seen by Cases
  #
  # Model objects considered:
  #
  # * {Contact}
  # * {Event}
  # * {Instrument}
  # * {Participant}
  # * {Person}
  # * {Response}
  # * {ResponseSet}
  #
  # A superposition is built by calling {#build} and passing hashes
  # representing original and proposed data.  The superposition is represented
  # in {#contacts}, {#events}, etc. with a hash of the format
  #
  #     {
  #       entity_id => {
  #         :original => (adapter object or nil),
  #         :proposed => (adapter object or nil),
  #         :current => (adapter object or nil)
  #       }
  #     }
  #
  # Nils may occur if the offline client returns newly instantiated or
  # corrupted entities.
  #
  # Superposition includes code to collapse its states.  See {Merge} for more
  # information.
  #
  #
  # Ancestry tracking
  # =================
  #
  # Superposition tracks the ancestry of objects present in the original and
  # proposed sets.  Ancestry for each object is available via the #ancestors
  # accessor.
  #
  # Superposition cannot build this ancestry data for the current state.
  #
  # An example:
  #
  #     sp = Superposition.new
  #     sp.build(original, proposed)
  #
  #     c = sp.contacts.first[:proposed]
  #     c.ancestors # => { :person_id => 'foobar' }
  #
  # This ancestry data is used by {Field::Merge} to create appropriate links
  # between newly instantiated entities.
  #
  # Event ancestry data contains the event contact _and_ the contact's
  # ancestors:
  #
  #     e = sp.events.first[:proposed]
  #     e.ancestors # => { :person_id => 'foobar', :contact => #<ContactHashAdapter ...> }
  #
  # Instruments, response sets, and responses follow suit:
  #
  #     r = sp.responses.first[:proposed]
  #     r.ancestors # => { :person_id => 'foobar',
  #                        :response_set => #<ResponseSetHashAdapter ...>,
  #                        :instrument => #<InstrumentHashAdapter ...>,
  #                        :event => #<EventHashAdapter ...>,
  #                        :contact => #<ContactHashAdapter ...>
  #                      }
  #
  # The adapter classes are defined in
  # {NcsNavigator::Core::Fieldwork::Adapters}.
  class Superposition
    include Field::Merge
    include Field::PscSync
    include Field::Scheduling
    include Field::ProtocolEligibility

    attr_accessor :contacts
    attr_accessor :events
    attr_accessor :instruments
    attr_accessor :participants
    attr_accessor :people
    attr_accessor :question_response_sets
    attr_accessor :response_sets
    attr_accessor :responses
    attr_accessor :eligible_participants

    ##
    # The staff ID of the user building the superposition.
    #
    # This is used by some adapters, i.e. {Adapters::Instrument::ModelAdapter}.
    attr_accessor :staff_id

    ##
    # By default, this logger throws messages to the Rails logger.
    attr_accessor :logger

    def initialize
      self.contacts = {}
      self.events = {}
      self.instruments = {}
      self.participants = {}
      self.people = {}
      self.question_response_sets = {}
      self.response_sets = {}
      self.responses = {}
      self.eligible_participants = []
      
      self.logger = Rails.logger
    end

    def build(original, proposed)
      set_original(original)
      set_proposed(proposed)
      set_current

      build_question_response_sets
    end

    def set_original(data)
      set_state(:original, data)
    end

    def set_proposed(data)
      set_state(:proposed, data)
    end

    def set_current
      hierarchy(:current) do |h|
        set_current_state(h, ::Contact, 'contact_id')
        set_current_state(h, ::Event, 'event_id')
        set_current_state(h, ::Instrument, 'instrument_id')
        set_current_state(h, ::Participant, 'p_id')
        set_current_state(h, ::Person, 'person_id')
        set_current_state(h, ::Response.for_merge, 'api_id')
        set_current_state(h, ::ResponseSet, 'api_id')
      end
    end

    def build_question_response_sets
      res = {}

      responses.each do |_, state|
        state.each do |state_name, response|
          key = [response.question_public_id, response.response_set_public_id]

          res[key] ||= {}
          res[key][state_name] ||= QuestionResponseSet.new
          res[key][state_name] << response
        end
      end

      self.question_response_sets = res
    end

    %w(contacts events instruments participants).each do |collection|
      class_eval <<-END
        def current_#{collection}
          #{collection}.map { |_, state| state[:current].target }
        end
      END
    end

    def set_state(state, data)
      hierarchy(state) do |h|
        data['participants'].each { |p| add_participant(h, p) }
        data['contacts'].each { |c| add_contact(h, c) }
      end
    end

    def set_current_state(h, entity, public_id, &block)
      collection = entity.name.pluralize.underscore

      entity.where(public_id => send(collection).keys.uniq).each do |e|
        h.add(entity.name, e, public_id, &block)
      end
    end

    def add_participant(h, participant)
      h.add(:participant, participant, 'p_id') do |h|
        participant['persons'].each do |person|
          h.add(:person, person, 'person_id')
        end
      end
    end

    def add_contact(h, contact)
      h.hierarchy(:person_id => contact['person_id']) do |h|
        h.add(:contact, contact, 'contact_id') do |h|
          contact['events'].each { |e| add_event(h, e) }
        end
      end
    end

    def add_event(h, event)
      h.add(:event, event, 'event_id') do |h|
        event['instruments'].each { |i| add_instrument(h, i) }
      end
    end

    def add_instrument(h, instrument)
      h.add(:instrument, instrument, 'instrument_id') do |h|
        instrument['response_sets'].each { |rs| add_response_set(h, rs) }
      end
    end

    def add_response_set(h, response_set)
      h.add(:response_set, response_set, 'uuid') do |h|
        # FYI: The responses key should always exist, but there's currently
        # a bug in Surveyor that makes that not the case.
        #
        # See https://github.com/NUBIC/surveyor/issues/294.
        responses = response_set['responses']

        if responses
          responses.each { |r| h.add(:response, r, 'uuid') }
        end
      end
    end

    def hierarchy(state)
      ctx = Context.new(state, self, {})

      yield ctx
    end

    class Context < Struct.new(:state, :superposition, :ancestors)
      include Field::Adoption

      def add(entity, object, key)
        collection = entity.to_s.pluralize.underscore
        c = superposition.send(collection)
        kv = object[key]

        unless c.has_key?(kv)
          c[kv] = {}
        end

        adapter = case object
                  when Hash; adapt_hash(entity, object)
                  else adapt_model(object)
                  end

        c[kv][state] = adapter ? adapter : object

        adapter.superposition = superposition

        if adapter.respond_to?(:ancestors=)
          adapter.ancestors = ancestors
        end

        if block_given?
          yield self.class.new(state, superposition, ancestors.merge(entity => c[kv][state]))
        end
      end

      def hierarchy(additional = {})
        yield dup.tap { |d| d.ancestors = d.ancestors.merge(additional) }
      end
    end
  end
end
