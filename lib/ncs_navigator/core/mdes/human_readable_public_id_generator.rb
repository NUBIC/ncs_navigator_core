require 'forwardable'

module NcsNavigator::Core::Mdes
  class HumanReadablePublicIdGenerator
    class << self
      ##
      # @private
      def prng
        @prng ||= Random.new
      end
    end

    extend Forwardable
    def_delegators self, :prng

    # These characters are selected to be easy to distinguish when written
    # down, regardless of case. (E.g., 0 and O are omitted because they are
    # similar as is the set 1, L, I.)
    CHARS = %w(2 3 4 5 6 7 8 9 a b c d e f h k r s t w x y z)
    # Pattern is like SSN because it seems like that rhythm might be familiar.
    DEFAULT_PATTERN = [3, 2, 4]

    attr_accessor :model_class, :public_id_field

    ##
    # @param options
    # @option options :pattern [Array<Fixnum>]
    def initialize(options={})
      @pattern = options.delete(:pattern) || DEFAULT_PATTERN
      @psu = options.delete(:psu) || nil

      unless options.empty?
        fail "Unknown option#{'s' if options.size > 2} #{options.keys.map(&:inspect).join(', ')}."
      end
    end

    def generate
      id = new_id
      # This mechanism will not handle the case where two transactions
      # simultaneously create and commit the same ID. That is so vanishingly
      # unlikely that it doesn't warrant addressing at this time. If it needs
      # to be made less likely, we can always add another character to the
      # IDs.
      if can_check_for_collisions?
        until @model_class.where(@public_id_field => id).count == 0
          id = new_id
        end
      end
      id
    end

    private

    def new_id
      id = @pattern.collect { |segment_length|
        to_chars(
          prng.rand(CHARS.size ** segment_length),
          segment_length
        )
      }.join('-')
      # prefix the last three digits of the psu + an underscore to the id
      if @psu && @psu.length >= 3
        last_three_digits = @psu[(@psu.length - 3), @psu.length]
        id = "#{last_three_digits}_#{id}"
      end
      id
    end

    def to_chars(i, size)
      converted = ''
      while i > 0
        converted << CHARS[i % CHARS.size]
        i /= CHARS.size
      end
      ("%#{size}s" % converted).gsub(' ', CHARS[0])
    end

    def can_check_for_collisions?
      @model_class && @public_id_field
    end
  end
end
