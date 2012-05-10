require 'ncs_navigator/core'

module NcsNavigator::Core::Fieldwork
  ##
  # Methods for reifying associations in fieldwork sets.
  module Associations
    ##
    # Given ancestry data of contacts, events, and instruments, constructs
    # representations of {ContactLink}s from that data.
    #
    # Only the most specific representations are returned: so, for example, if
    # two representations (C, nil, nil, PE) and (C, E, I, PE) can be derived
    # from ancestry data, then (C, E, I, PE) is the only one that will be
    # returned.  However, in the case of two representations (C, E, I, PE) and
    # (C', nil, nil, PE), both representations will be returned, because they
    # do not address the same entities.
    #
    # The output from this method can be used as the input to
    # #find_contact_links.
    #
    # All objects in each set should respond to #ancestors with a hash.  The
    # hash may contain the keys :contact, :event, :instrument, or :person_id;
    # each key, if present, should resolve to an adapter object or (in the case
    # of person_id) a string.
    #
    # @param [Array<#ancestors>] contacts
    # @param [Array<#ancestors>] events
    # @param [Array<#ancestors>] instruments
    # @return a list of tuples (contact_id, event_id, instrument_id, person_id)
    #   representing {ContactLink}s
    def coalesce_contact_links(contacts, events, instruments)
    end

    ##
    # Given a list of tuples (contact_id, event_id, instrument_id, person_id),
    # resolves that list to {ContactLink}s in Core.  Returns two lists: a list
    # of ContactLinks and a list of tuples that could not be resolved to
    # ContactLinks.
    def find_contact_links(tuples)
    end

    ##
    # Links Instruments to their Events.   Assumes that all Events have been
    # successfully saved.
    def link_instruments_to_events(instruments, events)
    end

    ##
    # Locates all referenced {ResponseSet}s in a list of {ResponseGroup}s.
    # Returns two lists: a list of ResponseSets and a list of ResponseGroups
    # without resolvable ResponseSets.
    def find_response_sets(response_groups)
    end

    ##
    # Links Responses to their ResponseSets.  Assumes that all ResponseSets
    # have been previously saved.
    def link_responses_to_response_sets(response_groups)
    end
  end
end
