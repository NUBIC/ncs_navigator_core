require 'forwardable'

##
# A value object for {Merge#conflict_report}.
#
# This class provides an iterator that yields entities, attributes, and
# superpositions in a predicatable order, easing presentation of the conflict report.
#
# This class also includes a module for resolving NCS coded attributes in
# conflict reports.
class ConflictReport
  extend Forwardable
  include Enumerable

  def_delegator :@raw, :blank?

  def initialize(json)
    @raw = JSON.parse(json) if json
  end

  def to_s
    @raw.to_json
  end

  # Redefining #to_s messes with #inspect.
  def inspect
    "#<#{self.class.name}:0x#{object_id.to_s(16)} @raw=#{@raw}>"
  end
end
