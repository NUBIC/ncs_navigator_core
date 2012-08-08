# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module Field
  ##
  # A Superposition represents three states of the entities involved with a
  # {Fieldwork} set:
  #
  # 1. the entities as they were when the Fieldwork set was generated
  #    (original),
  # 2. the entities an offline client sees them (proposed), and
  # 3. the entities as Core sees them (current).
  #
  # States 1 and 2 are set via {#set_original} and {#set_proposed}.  State
  # 3 is set by invoking {#resolve_current}, which attempts to resolve all
  # entities referenced in both the original and proposed sets.
  #
  # Entities involved with the Fieldwork set are segregated by class.  Each
  # entity map has the form
  #
  #     {
  #       entity_id => {
  #         :original => (adapter object or nil),
  #         :proposed => (adapter object or nil),
  #         :current => (adapter object or nil)
  #       }
  #     }
  #
  # Nils may occur if i.e. the offline client returns newly instantiated or
  # corrupted entities.
  #
  # The adapter classes can be found in
  # {NcsNavigator::Core::Fieldwork::Adapters}, and the tools to generate those
  # classes can be found in tools/.
  #
  #
  # Entities considered
  # ===================
  #
  # A Superposition has provisions for the following entities:
  #
  # * {Contact}
  # * {Event}
  # * {Instrument}
  # * {Participant}
  # * {Person}
  # * {Response}
  # * {ResponseSet}
  #
  #
  # Performing a merge
  # ==================
  #
  # Once a Superposition has been built, you can mix in a merge algorithm
  # to collapse the states of the superposition.  The default algorithm is
  # implemented in {Merge}.
  class Superposition
    include Merge

    attr_accessor :contacts
    attr_accessor :events
    attr_accessor :instruments
    attr_accessor :participants
    attr_accessor :people
    attr_accessor :response_sets
    attr_accessor :responses

    ##
    # By default, this logger throws messages to a bit bucket.  If you want log
    # messages, provide your own logger.
    attr_accessor :logger

    def initialize
      self.contacts = {}
      self.events = {}
      self.instruments = {}
      self.participants = {}
      self.people = {}
      self.response_sets = {}
      self.responses = {}

      self.logger = Logger.new(nil)
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
        set_current_state(h, ::Response, 'api_id')
        set_current_state(h, ::ResponseSet, 'api_id')
      end
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
      include NcsNavigator::Core::Fieldwork::Adapters

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

        if adapter
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
