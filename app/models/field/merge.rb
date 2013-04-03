# -*- coding: utf-8 -*-

require 'ncs_navigator/core'

require 'case'
require 'facets/hash/weave'
require 'forwardable'
require 'set'

module Field
  ##
  # Performs a 3-way merge across the current state of Core's datastore, a
  # fieldwork set sent to a field client, and a corresponding fieldwork set
  # received from a field client.
  #
  # Currently, the following entities are merged:
  #
  # * {Contact}
  # * {Event}
  # * {Instrument}
  # * {Response} via {QuestionResponseSet}
  # * {ResponseSet}
  # * {Participant}
  # * {Person}
  #
  #
  # Overview
  # ========
  #
  # There are three states for each entity:
  #
  # Original: the state of the entity at fieldwork set checkout
  # Current: the state of the entity at merge start
  # Proposed: the state of the entity from Field
  #
  # Any of the three states may also be blank; to the merge algorithm, this
  # means "the entity does not exist in the given state".
  #
  # Merge, then, is a process of determining a new current state.
  #
  #
  # Atomic vs. non-atomic merge
  # ===========================
  #
  # Contacts, Events, Persons, Participants, ResponseSets, and Instruments can
  # all be merged non-atomically, which means that we can commit changes even
  # in the presence of conflicts.  (Also, we can retry the merge on those
  # entities and progress towards a fully merged state.)
  #
  # QuestionResponseSets, on the other hand, must be merged atomically: if
  # there exist conflicts on any attribute on any Response, none of the
  # Responses in the group can be merged.
  #
  # The difference, then, is one of merge granularity.  It makes sense to merge
  # individual attributes on operational data; however, because responses in
  # surveys can be related to each other in ways that are difficult to merge,
  # we take a conservative all-or-nothing approach.
  #
  # (Just to be clear, this has nothing to do with database transactions; all
  # merge commits occur in the scope of a single transaction.)
  #
  #
  # Resolution algorithm
  # ====================
  #
  # First, we check only whether entities are blank.  If original and current
  # are blank, we can just accept proposed as-is.
  #
  # original#blank?   current#blank?    proposed#blank?   Result
  # --------------------------------------------------------------
  # true              true              true              blank
  # true              true              false             proposed
  # true              false             true              conflict
  # true              false             false             resolve
  # false             true              true              blank
  # false             true              false             conflict
  # false             false             true              current
  # false             false             false             resolve
  #
  # Where the action is "resolve", we look at the entity or attributes
  # (depending on atomicity) and apply the following decision table, where X,
  # Y, and Z represent non-blank values:
  #
  # original    current   proposed    result
  # ------------------------------------------
  # blank       blank     X           X
  # blank       X         blank       X
  # blank       X         X           X
  # blank       X         Y           conflict
  # X           X         X           X
  # X           X         Y           Y
  # X           Y         X           Y
  # X           Y         Y           Y
  # X           Y         Z           conflict
  #
  #
  # Concurrency considerations
  # ==========================
  #
  # While it is possible to concurrently run multiple merges on the same subset
  # of entities, only one merge can win an update race.
  #
  # All entities involved in the merge use ActiveRecord's optimistic locking
  # mechanism, and Merge#save will re-raise ActiveRecord::StaleObjectError.
  #
  #
  # Participant/Person considerations
  # =================================
  #
  # Person data is only partially merged by this process.  Contact information
  # for a person (address, email, phone) is handled by
  # {PregnancyScreenerOperationalDataExtractor}.  See
  # {ResponseSet#extract_operational_data} for more information.
  module Merge
    attr_accessor :logger

    ##
    attr_accessor :conflicts

    def merge
      self.conflicts = ConflictReport.new

      contacts.each { |id, state| merge_entity(state, 'Contact', id) }
      events.each { |id, state| merge_entity(state, 'Event', id) }
      instruments.each { |id, state| merge_entity(state, 'Instrument', id) }
      response_sets.each { |id, state| merge_entity(state, 'ResponseSet', id) }
      people.each { |id, state| merge_entity(state, 'Person', id) }
      participants.each { |id, state| merge_entity(state, 'Participant', id) }
      question_response_sets.each { |id, state| merge_entity(state, 'QuestionResponseSet', id) }
    end

    ##
    # Saves the current state of all merged entities.
    #
    # For more complete error reporting, this method attempts to save all
    # entities regardless of whether or not a previous entity or set of
    # entities failed to save.  However, it will return true if and only if all
    # entities were saved.
    #
    # When data dependencies exist, this can lead to spurious errors; however,
    # that can be dealt with by just looking further up in the log.  There's no
    # similar way to discover errors that aren't reported due to an early
    # abort.
    def save
      collections = [participants, people,
                     contacts, events, instruments,
                     response_sets,
                     question_response_sets
                    ].map { |c| current_for(c).compact }

      ActiveRecord::Base.transaction do
        collections.map { |c| save_collection(c) }.all?.tap do |ok|
          if ok
            logger.debug { "Re-saving response sets" }
            current_for(response_sets).select { |rs| rs }.each { |rs| rs.target.reload.save }
            logger.info { 'Merge saved' }
          else
            logger.fatal { 'Errors raised during save; rolling back' }
            raise ActiveRecord::Rollback
          end
        end
      end
    end

    def conflicted?
      !conflicts.blank?
    end

    module_function

    N = Case::Not
    S = Case::Struct.new(:o, :c, :p)

    def merge_entity(state, entity, id)
      o = state[:original]
      c = state[:current]
      p = state[:proposed]

      case [o.blank?, c.blank?, p.blank?]
      when [true,     true,     false]; accept_proposed(p, entity, id, state)
      when [true,     false,    false]; resolve(o, c, p, entity, id)
      when [false,    true,     false]; add_conflict(entity, id, :self, o, c, p)
      when [false,    false,    false]; resolve(o, c, p, entity, id)
      end
    end

    def accept_proposed(proposed, entity, id, state)
      logger.debug { "Trivially accepted proposed data for #{entity} #{id}" }

      state[:current] = proposed.to_model
    end

    def resolve(o, c, p, entity, id)
      if c.merge_atomically?
        resolve_atomic(o, c, p, entity, id)
      else
        resolve_nonatomic(o, c, p, entity, id)
      end
    end

    ##
    # @private
    def resolve_atomic(o, c, p, entity, id)
      collapse_with_conflict_tracking(o, c, p, entity, id, :self) do |state|
        c.patch(state)
      end
    end

    ##
    # @private
    def resolve_nonatomic(o, c, p, entity, id)
      patch = {}

      attrs_to_merge = c.class.accessible_attributes

      attrs_to_merge.each do |attr|
        vo = o[attr] if o
        vc = c[attr]
        vp = p[attr]

        logger.debug { "Resolving #{attr}: [o, c, p] = #{[vo, vc, vp].inspect}" }

        collapse_with_conflict_tracking(vo, vc, vp, entity, id, attr) do |state|
          patch[attr] = state
        end
      end

      c.patch(patch)
    end

    ##
    # @private
    def collapse_with_conflict_tracking(o, c, p, entity, id, attr)
      result = collapse(o, c, p)

      if result == :conflict
        add_conflict(entity, id, attr, o, c, p)
      else
        logger.debug { "Collapsed [o, c, p] = #{[o, c, p].inspect} to #{result.inspect}" }
        yield result
      end
    end

    ##
    # @private
    def collapse(o, c, p)
      case S[o, c, p]
      when S[nil, nil, p]; p
      when S[nil, c, nil]; c
      when S[nil, c, c];   c
      when S[nil, c, p];   :conflict
      when S[o, o, o];     o
      when S[o, o, p];     p
      when S[o, c, o];     c
      when S[o, c, c];     c
      when S[o, c, p];     :conflict
      end
    end

    ##
    # Adds and logs conflicts.
    #
    # @private
    def add_conflict(entity, id, attr, o, c, p)
      logger.warn { "Detected conflict on #{entity} #{attr}: [o, c, p] = #{[o, c, p].inspect}" }

      conflicts.add(entity, id, attr, o, c, p)
    end

    ##
    # @private
    # @return Boolean
    def save_collection(c)
      ok = ensure_prerequisites(c)
      ok = ok && save_entities(c)
      ok = ok && ensure_postrequisites(c)
    end

    ##
    # @private
    def ensure_prerequisites(c)
      pending = c.map(&:pending_prerequisites).inject({}, &:weave)
      map = resolve_requisites(pending)

      c.map { |m| m.ensure_prerequisites(map) }.all?
    end

    ##
    # @private
    def save_entities(c)
      c.map do |entity|
        entity.save.tap { |ok| log_errors_for(entity, ok) }
      end.all?
    end

    ##
    # @private
    def ensure_postrequisites(c)
      pending = c.map(&:pending_postrequisites).inject({}, &:weave)
      map = resolve_requisites(pending)

      c.map { |m| m.ensure_postrequisites(map) }.all?
    end

    ##
    # @private
    def resolve_requisites(reqs)
      m = {}.tap do |map|
        reqs.each do |model, public_ids|
          map[model] = model.public_id_to_id_map(public_ids)
        end
      end

      IdMap.new(m)
    end

    ##
    # @private
    def current_for(c)
      c.map { |public_id, state| state[:current] }
    end

    def log_errors_for(entity, ok)
      return if ok

      public_id = entity.respond_to?(:public_id) ? entity.public_id : '(unknown)'

      logger.fatal { "[#{entity.class} #{public_id}] #{entity.class} could not be saved" }

      entity.errors.to_a.each do |error|
        logger.fatal { "[#{entity.class} #{public_id}] Validation error: #{error.inspect}" }
      end
    end
  end
end
