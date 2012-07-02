

require 'ncs_navigator/core'

require 'case'

module NcsNavigator::Core::Fieldwork
  ##
  # Performs a 3-way merge across the current state of Core's datastore, a
  # fieldwork set sent to a field client, and a corresponding fieldwork set
  # received from a field client.
  #
  # Currently, four entities are merged: {Contact}, {Event}, {Instrument},
  # and {ResponseSet}.
  #
  #
  # The contact and event merge algorithm
  # =====================================
  #
  # Nomenclature
  # ------------
  #
  # * E(O): the entity as it existed when the fieldwork set was generated,
  #         i.e. the original state of an entity
  # * E(C): the entity as it exists at merge time
  # * E(P): the entity as proposed by a field client
  # * A: the merge action
  #
  #
  # Entity states
  # -------------
  #
  # * nil: the entity doesn't exist
  # * new: the entity is unpersisted in one or more processes
  # * exist: the entity has been persisted
  #
  # It is impossible for E(P) to ever be in state "exist": by definition,
  # E(P) is the proposed state, and therefore has not been persisted.
  #
  #
  # Actions
  # -------
  #
  # * none: do nothing
  # * new: create a new contact
  # * conflict: signal a conflict
  # * resolve: resolve the changes, signaling a conflict if unsuccessful
  #
  #     E(O)    E(C)    E(P)    A
  #     ------------------------------------
  #     nil     nil     nil     none
  #     nil     nil     new     new
  #     nil     new     nil     none [1]
  #     nil     new     new     conflict [2]
  #     nil     exist   nil     none
  #     nil     exist   new     resolve
  #     exist   nil     nil     none
  #     exist   nil     new     conflict
  #     exist   new     new     conflict [2]
  #     exist   exist   nil     none
  #     exist   exist   new     resolve
  #
  #
  # [1]: This can occur if another merge is running concurrently: merge A
  # (the merge of concern) won't see the results of merge B, so it won't do
  # anything about the newly created entity.
  #
  # [2]: This also can occur with concurrent merges; however, in this case,
  # an ActiveRecord::StaleObjectError will be raised by one of the merges.
  # When this occurs, the failing merge will be restarted.
  #
  #
  # Attribute merge
  # ===============
  #
  # This algorithm is used on a per-attribute basis in the resolve phase of the
  # entity merge algorithm.
  #
  #
  # Nomenclature
  # ------------
  #
  # * O: the original state of the attribute
  # * C: the current state of the attribute
  # * P: the proposed state of the attribute
  # * A: the merge action
  #
  #
  # Entity states
  # -------------
  #
  # An attribute may have one of the states X, Y, or Z, where
  #
  #     X != Y != Z != nil
  #
  # .
  #
  # Actions
  # -------
  #
  # * X: use value X
  # * Y: use value Y
  # * conflict: signal a conflict
  #
  #   O     C     P     R
  #   --------------------------
  #   nil   nil   X     X
  #   nil   X     nil   X
  #   nil   X     X     X
  #   nil   X     Y     conflict
  #   X     X     X     X
  #   X     X     Y     Y
  #   X     Y     X     Y
  #   X     Y     Y     Y
  #   X     Y     Z     conflict
  #
  #
  # Responses are grouped by question
  # =================================
  #
  # Responses are first grouped by question; those groups are then merged
  # according to the above algorithm.
  #
  # @see https://code.bioinformatics.northwestern.edu/issues/wiki/ncs-navigator-core/Field_-%3E_Core_merge#Response-set
  module Merge
    attr_accessor :logger
    attr_accessor :conflicts

    def merge
      self.conflicts = ConflictReport.new

      contacts.each { |id, state| merge_entity(state, 'Contact', id) }
      events.each { |id, state| merge_entity(state, 'Event', id) }
      instruments.each { |id, state| merge_entity(state, 'Instrument', id) }
      response_groups.each { |id, state| merge_entity(state, 'ResponseGroup', id) }
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
      ActiveRecord::Base.transaction do
        [contacts, events, instruments, response_groups].map { |c| save_collection(c) }.all?.tap do |res|
          unless res
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

      case S[o, c, p]
      when S[nil, nil, N[nil]] then
        state[:current] = p.to_model
      when S[nil, N[nil], N[nil]]
        resolve(o, c, p, entity, id)
      when S[N[nil], nil, N[nil]]
        conflicts.add(entity, id, :self, o, c, p)
      when S[N[nil], N[nil], N[nil]]
        resolve(o, c, p, entity, id)
      end
    end

    def resolve(o, c, p, entity, id)
      if [o, c, p].all? { |e| e.nil? || ResponseGroup === e }
        return resolve_response_group(o, c, p, entity, id)
      end

      {}.tap do |h|
        attrs_to_merge = c.class.accessible_attributes

        attrs_to_merge.each do |attr|
          vo = o[attr] if o
          vc = c[attr]
          vp = p[attr]

          case S[vo, vc, vp]
          when S[nil, nil, vp];  h[attr] = vp
          when S[nil, vc, nil];  h[attr] = vc
          when S[nil, vc, vc];   h[attr] = vc
          when S[nil, vc, vp];   conflicts.add(entity, id, attr, vo, vc, vp)
          when S[vo, vo, vo];    h[attr] = vo
          when S[vo, vo, vp];    h[attr] = vp
          when S[vo, vc, vo];    h[attr] = vc
          when S[vo, vc, vc];    h[attr] = vc
          when S[vo, vc, vp];    conflicts.add(entity, id, attr, vo, vc, vp)
          end
        end

        c.attributes = h
      end
    end

    def resolve_response_group(o, c, p, entity, id)
      unless c =~ p
        conflicts.add(entity, id, :self, o, c, p)
        return
      end

      c.answer_ids = p.answer_ids
      c.values = p.values
    end

    ##
    # @private
    # @return Boolean
    def save_collection(c)
      c.map do |public_id, state|
        current = state[:current]

        next true unless current

        current.save.tap { |ok| log_errors_for(public_id, current, ok) }
      end.all?
    end

    def log_errors_for(public_id, entity, ok)
      return if ok

      logger.fatal { "[#{entity.class} #{public_id}] #{entity.class} could not be saved" }

      entity.errors.to_a.each do |error|
        logger.fatal { "[#{entity.class} #{public_id}] Validation error: #{error.inspect}" }
      end
    end
  end
end
