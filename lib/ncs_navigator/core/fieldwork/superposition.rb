# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

module NcsNavigator::Core::Fieldwork
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
  #         :original => (a JSON object or nil),
  #         :proposed => (a JSON object or nil),
  #         :current => (an ActiveRecord model or nil)
  #       }
  #     }
  #
  # Nils may occur if i.e. the offline client returns newly
  # instantiated or corrupted entities.
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
  # * {ResponseSet}
  #
  #
  # Performing a merge
  # ==================
  #
  # Once a Superposition has been built, you can mix in a merge algorithm
  # to collapse the states of the superposition.
  #
  # @see Merge
  class Superposition
    include Adapters

    attr_accessor :contacts
    attr_accessor :events
    attr_accessor :instruments
    attr_accessor :participants
    attr_accessor :people
    attr_accessor :responses
    attr_accessor :response_sets

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
      self.responses = {}
      self.response_sets = {}

      self.logger = Logger.new(nil)
    end

    def set_original(data)
      set_state(:original, data)
    end

    def set_proposed(data)
      set_state(:proposed, data)
    end

    def resolve_current
      set_current_state(:contacts, Contact, 'contact_id')
      set_current_state(:events, Event, 'event_id')
      set_current_state(:instruments, Instrument, 'instrument_id')
      set_current_state(:participants, Participant, 'p_id')
      set_current_state(:people, Person, 'person_id')
      set_current_state(:response_sets, ResponseSet, 'api_id')
      set_current_state(:responses, Response, 'api_id') { |q| q.includes(:question, :answer) }
    end

    def set_state(state, data)
      data['contacts'].each do |contact|
        add(state, :contacts, contact, 'contact_id') { |o| adapt_hash(:contact, o) }

        contact['events'].each do |event|
          add(state, :events, event, 'event_id') { |o| adapt_hash(:event, o) }

          event['instruments'].each do |instrument|
            add(state, :instruments, instrument, 'instrument_id')
            add(state, :response_sets, instrument['response_set'], 'uuid') { |o| adapt_hash(:response_set, o) }

            responses = instrument['response_set']['responses']

            # FYI: The responses key should always exist, but there's currently
            # a bug in Surveyor that makes that not the case.
            #
            # See https://github.com/NUBIC/surveyor/issues/294.
            if responses
              responses.each do |response|
                add(state, :responses, response, 'uuid') { |o| adapt_hash(:response, o) }
              end
            end
          end
        end
      end

      data['participants'].each do |participant|
        add(state, :participants, participant, 'p_id')

        participant['persons'].each do |person|
          add(state, :people, person, 'person_id') { |o| adapt_hash(:person, o) }
        end
      end
    end

    def set_current_state(collection, entity, public_id)
      q = entity.where(public_id => send(collection).keys.uniq)
      q = (yield q if block_given?) || q

      q.each { |e| add(:current, collection, e, public_id) { |m| adapt_model(m) } }
    end

    def add(state, collection, object, key)
      c = send(collection)
      k = object[key]

      unless c.has_key?(k)
        c[k] = {}
      end

      c[k][state] = (yield object if block_given?) || object
    end
  end
end
