module Field
  ##
  # The merge process deals with two data structures.  They are:
  #
  # 1. Cases' models.
  # 2. Hashes built from JSON representations of (1).
  # 
  # To simplify merge code, Field::Adapter defines a property access interface
  # common to both data structures.  Some examples:
  #   
  #     h = Person::HashAdapter.new({})
  #
  #     p = Person.new
  #     m = Person::ModelAdapter.new(p)
  #
  #     h.first_name = 'foo'  # hash contents: { 'first_name' => 'foo' }
  #     m.first_name = 'foo'  # p.first_name == 'foo'
  #
  # Equality between adapted objects of the same type is also defined:
  #
  #     a1 = Person::HashAdapter.new({})
  #     a2 = Person::HashAdapter.new({})
  #
  #     a1 == a2      # => true
  #
  # Neither Field::Adapter nor its descendants HashAdapter and ModelAdapter
  # should be used directly.  Instead, use the model-specific adapters under
  # Field::Adapters::*.
  #
  # @private
  class Adapter
    include ActiveModel::MassAssignmentSecurity

    ##
    # The wrapped object.
    attr_accessor :target

    ##
    # The {Superposition} this adapter belongs to.
    attr_accessor :superposition

    ##
    # Builds attribute accessors.
    #
    # The accessors defined by this method require that the adapter define the
    # following methods:
    #
    # * #set(attr, value)
    # * #get(attr)
    #
    # {HashAdapter} and {ModelAdapter} do this.
    def self.attr_accessors(attrs)
      attrs.each do |attr|
        to, from = case attr
                   when String; [attr, attr]
                   when Hash; attr.to_a.first
                   else raise "Invalid attribute spec #{attr.inspect}"
                   end

        define_method(to) { get(from) }
        define_method("#{to}=") { |v| set(from, v) }
        attr_accessible to
      end
    end

    ##
    # Composes a method with a transformer method.
    #
    # An example:
    #
    #     class ThingAdapter
    #       transform :created_at, :to_date
    #     end
    #
    # ThingAdapter#created_at= may be still be invoked with any value.
    # However, when ThingAdapter#created_at is invoked, the return value will
    # be this:
    #
    #     ThingAdapter#to_date(ThingAdapter#created_at)
    #
    # This is often used to parse strings into Dates and BigDecimals.
    def self.transform(attr, with)
      old = instance_method(attr)
      trans = instance_method(with)

      define_method(attr) do
        value = old.bind(self).call
        trans.bind(self).call(value)
      end
    end

    def initialize(target)
      self.target = target
    end

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def ==(other)
      if other.respond_to?(:to_hash)
        target.to_hash == other.to_hash
      else
        other.target == target
      end
    end
  end
end
