module Field
  module Adapter
    extend ActiveSupport::Concern

    included do
      include ActiveModel::MassAssignmentSecurity
    end

    attr_accessor :target

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
      other.target == target && other.ancestors == ancestors
    end

    module ClassMethods
      ##
      # Builds attribute accessors.
      #
      # The accessors defined by this method require that the adapter define the
      # following methods:
      #
      # * #set(attr, value)
      # * #get(attr)
      #
      # {HashBehavior} and {ModelBehavior} do this.
      def attr_accessors(attrs)
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

      def transform(attr, with)
        old = instance_method(attr)
        trans = instance_method(with)

        define_method(attr) do
          value = old.bind(self).call
          trans.bind(self).call(value)
        end
      end
    end
  end
end
