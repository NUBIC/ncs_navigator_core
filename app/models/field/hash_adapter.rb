require 'bigdecimal'
require 'date'

module Field
  ##
  # Type coercions to make an attribute from a hash or an ActiveRecord model
  # be appropriate for an ActiveRecord model.
  class HashAdapter < Adapter
    include Field::Adoption

    attr_accessor :ancestors

    def initialize(*)
      super

      self.ancestors ||= {}
    end

    def to_model
      adapt_model(model_class.new).tap do |m|
        m.source = self
        m.superposition = superposition
        m.patch(target)
      end
    end

    def set(attr, value)
      target[attr] = value
    end

    def get(attr)
      target[attr]
    end

    def to_date(x)
      case x
      when Date; x
      when NilClass; x
      else
        begin
          Date.parse(x)
        rescue ArgumentError
        end
      end
    end

    def to_bigdecimal(x)
      case x
      when BigDecimal; x
      when NilClass; x
      else BigDecimal.new(x)
      end
    end
  end
end
