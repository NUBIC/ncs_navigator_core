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

  def initialize(json = nil)
    @raw = (JSON.parse(json) if json) || {}
  end

  def to_s
    @raw.to_json
  end

  def to_hash
    @raw.dup
  end

  def ==(other)
    @raw == other.to_hash
  end

  def each
    @raw.keys.sort.map do |type|
      entities = @raw[type]

      entities.keys.sort.map do |public_id|
        attributes = entities[public_id]

        e = Entity.new(type, public_id)
        as = attributes.keys.sort.map do |name|
          state = attributes[name]

          Attribute.new(name, state['current'], state['original'], state['proposed'])
        end

        yield e, as
      end
    end
  end

  def add(entity, entity_id, key, original, current, proposed)
    @raw.deep_merge!({
      entity => {
        entity_id => {
          key => {
            'original' => original,
            'current' => current,
            'proposed' => proposed
          }
        }
      }
    })
  end

  # Redefining #to_s messes with #inspect.
  def inspect
    "#<#{self.class.name}:0x#{object_id.to_s(16)} @raw=#{@raw}>"
  end

  Entity = Struct.new(:type, :public_id)

  class Attribute < Struct.new(:name, :current, :original, :proposed)
    def humanize
      name.humanize
    end
  end
end
