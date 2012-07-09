require 'ncs_navigator/core'

module NcsNavigator::Core::Mdes
  # n.b.: this class is deliberately designed to make extracting out a
  # mixin to ease the creating of MdesTime later if needed.

  ##
  # Encapsulates an MDES date string. Such a string has the same
  # structure as a usual YYYY-MM-DD date, but may carry encoded
  # information in the year, month, or day positions instead of a
  # valid value.
  #
  # Instances are immutable after construction.
  class MdesDate
    ATTRIBUTE_NAMES = [:year, :month, :day]
    ATTRIBUTE_SCALES = { :year => 4, :month => 2, :day => 2 }

    ##
    # Creates a new instance. The sole argument may be a string or a
    # hash.
    #
    # If a string, it must match `/\d{4}-\d{2}-\d{2}` and will
    # be parsed into separate components.
    #
    # If a hash, it must have the keys `:year`, `:month`, and
    # `:day`. The value for each must be one of the following:
    #
    # * A positive integer, indicating a concrete year, month, or
    #   day. Years must not be abbreviated; months and days are
    #   1-based.
    # * A negative integer greater than -10 indicating a coded
    #   value.
    #
    # @param [String,Hash] source
    def initialize(source)
      @attributes = ATTRIBUTE_NAMES.inject({}) { |h, k| h.merge(k => -6) }
      case source
      when String
        parse_string(source)
      else
        parse_hash(source)
      end
    end

    def year
      @attributes[:year]
    end

    def month
      @attributes[:month]
    end

    def day
      @attributes[:day]
    end

    def parse_string(s)
      parts = ATTRIBUTE_NAMES.
        zip(s.split('-')).
        inject({}) { |h, (k, v)| h.merge(k => v) }
      parts.each do |k, v|
        @attributes[k] = if v =~ /^9/
                           v[1,1].to_i * -1
                         else
                           v.to_i
                         end
      end
    end
    private :parse_string

    def parse_hash(h)
      h.each do |k, v|
        @attributes[k] = v
      end
    end
    private :parse_hash

    ##
    # Does this date contain any coded (i.e., non-concrete)
    # components?
    #
    # @return [Boolean]
    def coded?
      @coded ||= ATTRIBUTE_NAMES.any? { |a| coded_attribute?(a) }
    end

    def coded_attribute?(attr)
      @attributes[attr] < 1
    end
    private :coded_attribute?

    ##
    # Provides a date if this object can be expressed exactly as a
    # ruby date (i.e., if this object is not a coded date).
    #
    # @return [Date,nil]
    def to_date
      @date ||= coded? ? nil : Date.new(*ATTRIBUTE_NAMES.collect { |a| @attributes[a] })
    end

    ##
    # Provides an approximate date by substituting 1 for a missing
    # month and/or day. If the year is missing, it still returns nil.
    #
    # @return [Date,nil]
    def to_approximate_date
      @to_approximate_date ||=
        if coded_attribute?(:year)
          nil
        elsif coded?
          Date.new(*ATTRIBUTE_NAMES.collect { |a| coded_attribute?(a) ? 1 : @attributes[a] })
        else
          to_date
        end
    end

    ##
    # @return [String] the MDES-compatible string representation of
    #   this date.
    def to_s
      @s ||= ATTRIBUTE_NAMES.collect { |a|
        if coded_attribute?(a)
          "9%s" % ((-@attributes[a]).to_s * (ATTRIBUTE_SCALES[a] - 1))
        else
          "%0#{ATTRIBUTE_SCALES[a]}d" % @attributes[a]
        end
      }.join('-')
    end

    ##
    # @return [String] an MDES-compatible representation of the
    #   approximate provided by {#to_approximate_date}.
    def to_approximate_s
      @approximate_s ||= to_approximate_date.try(:to_formatted_s)
    end
  end
end
