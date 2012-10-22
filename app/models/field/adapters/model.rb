require 'forwardable'

module Field::Adapters
  ##
  # To avoid tedious unboxing code, we want to treat model adapters as
  # ActiveRecord objects.  This module lets us do so by implementing relevant
  # parts of the ActiveModel / ActiveRecord APIs.
  #
  # This module also includes code to build a whitelist of mergeable attributes.
  module Model
    extend ActiveSupport::Concern
    extend Forwardable

    included do
      extend ActiveModel::Naming
    end

    attr_accessor :source

    ##
    # Used when generating a fieldwork set.
    #
    # @see Field::ScheduledActivityReport
    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

    def set(attr, value)
      target.send("#{attr}=", value)
    end

    def get(attr)
      target.send(attr)
    end

    ##
    # Applies changes to the wrapped model.
    def patch(attributes)
      sanitize_for_mass_assignment(attributes).each { |k, v| self[k] = v }
    end

    ##
    # By default, models can be merged on an attribute-by-attribute basis.
    def merge_atomically?
      false
    end

    def to_model
      self
    end

    ##
    # Unless otherwise specified, a model has no prerequisites.
    def pending_prerequisites
      {}
    end

    ##
    # Unless otherwise specified, a model has no postrequisites.
    def pending_postrequisites
      {}
    end

    ##
    # Default prerequisites are vacuously satisfied.
    def ensure_prerequisites(map)
      true
    end

    ##
    # Default postrequisites are vacuously satisfied.
    def ensure_postrequisites(map)
      true
    end

    # These methods are used in various field classes.
    def_delegators :target,
      :changed?,
      :destroy,
      :destroyed?,
      :errors,
      :mark_for_destruction,
      :marked_for_destruction?,
      :new_record?,
      :persisted?,
      :public_id,
      :save,
      :valid?
  end
end
