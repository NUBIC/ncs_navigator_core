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
  # * {Response}
  #
  # In the case of Response and ResponseSet, it may also build related
  # entities such as Answer and Question.
  #
  # 
  # Performing a merge
  # ==================
  #
  # Once a Superposition has been built, you can mix in a merge algorithm
  # to collapse the states of the superposition.
  #
  # @see MergeTheirs
  class Superposition
  end
end
