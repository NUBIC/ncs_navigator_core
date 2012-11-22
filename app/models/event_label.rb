##
# An {Event} starts its life in PSC as an activity label.  This label can be
# matched to an {NcsCode} that provides the event's name and type code.
#
# This class wraps a string with methods that perform the above mapping.  For
# efficient resolution of many labels, you can supply an eagerly loaded
# {NcsCode} collection.
class EventLabel
  ##
  # Word separators.
  SEPS = '[-_]'

  ##
  # We upcase any non-separator character at the beginning of the string or
  # non-separator character preceded by a separator.
  UPCASE = /^[^#{SEPS}]|(?<=#{SEPS})[^#{SEPS}]/

  def initialize(label)
    @label = label
  end

  ##
  # Maps the label to {NcsCode}-compatible display text.
  def display_text
    @label.
      gsub(/\s*-\s*/, '-').     # compress spaces around dashes
      gsub(UPCASE, &:upcase).   # upcase all starting letters
      split('_').               # underscores will become spaces
      map { |x| patch_up(x) }.  # patch up special cases
      join(' ')
  end

  ##
  # Uses {#display_text} to locate an {NcsCode} for the event label.
  #
  # This method accepts a display text -> {NcsCode} map that, if provided, will
  # be used for resolving codes.  If a map is not provided, a database query
  # will be issued.
  #
  # Returns an {NcsCode} if one can be found, nil otherwise.
  def ncs_code(map = nil)
    if map
      map[display_text]
    else
      NcsCode.for_list_name_and_display_text('EVENT_TYPE_CL1', display_text)
    end
  end

  ##
  # @private
  def patch_up(word)
    case word
    when /\b(?:to|in)\b/i; word.downcase
    when /\bpbs\b/i;  'PBS'
    else word
    end
  end
end
