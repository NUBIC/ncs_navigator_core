module Psc
  ##
  # Represents a label on a {Psc::ScheduledActivity}.
  #
  # Labels have three components, in the following order:
  #
  # 1. a type prefix
  # 2. MDES version (optional)
  # 3. label content
  #
  # These components are separated by colons (:).  Versioned labels have three
  # components; unversioned labels have two.  Labels with fewer than two
  # components are erroneous.
  #
  # The meaning of the label content is dependent on its type.  See e.g.
  # {EventLabel} and {InstrumentLabel} for examples.
  class ActivityLabel < Struct.new(:prefix, :mdes_version, :content)
    SEP = ':'

    ##
    # Initializes an ActivityLabel from its textual representation.
    #
    # @raise ArgumentError if 2 < c || c > 3, where c is the number of
    #   components
    def self.from_string(str)
      # We know our upper bound on component count, so there is no reason to
      # have to deal with an unbounded number of components.
      components = str.split(SEP, 3)

      if components.length < 2 || components.last.include?(SEP)
        raise ArgumentError, 'incorrect number of components'
      end

      new.tap do |l|
        l.prefix = components.first
        l.content = components.last

        if components.length == 3
          l.mdes_version = components[1]
        end
      end
    end

    ##
    # Returns whether or not this label has the given prefix.
    #
    # Comparisons are case-sensitive.
    def has_prefix?(prefix)
      self.prefix == prefix
    end

    ##
    # Returns whether or not this label is applicable to the given MDES
    # version.
    #
    # Labels without versions are applicable to *all* MDES versions.
    def for_mdes_version?(version)
      !versioned? || mdes_version == version
    end

    def versioned?
      !mdes_version.nil?
    end

    def to_s
      if prefix.blank? || content.blank?
        raise 'label with blank prefix or content has no string representation'
      end

      if versioned?
        "#{prefix}#{SEP}#{mdes_version}#{SEP}#{content}"
      else
        "#{prefix}#{SEP}#{content}"
      end
    end
  end
end
