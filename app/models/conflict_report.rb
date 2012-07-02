require 'forwardable'

##
# A value object for {Merge#conflict_report}.
#
# This class provides an iterator that yields entities, attributes, and
# superpositions in a predicatable order, easing presentation of the conflict report.
#
# This class also includes a module for resolving NCS coded attributes in
# conflict reports.
#
#
# Data structure
# ==============
#
# The conflict report is a JSON object of the form
#
#     {
#       entity_name: {
#         entity1_public_id: {
#           attr1: {
#             "original": value,
#             "current": value,
#             "proposed": value
#           },
#           ...
#         },
#         ...
#       },
#       ...
#     }
#
# An example:
#
#     {
#         "Contact": {
#             "af72e358-e856-4859-baf5-c61134ddfa4d": {
#                 "disposition": {
#                     "current": "0",
#                     "original": "-4",
#                     "proposed": "1"
#                 }
#             },
#             "ba8aa819-6bc3-4244-8cc5-1ed9d6201966": {
#                 "language": {
#                     "current": "1",
#                     "original": "-4",
#                     "proposed": "2"
#                 }
#             }
#         },
#         "Event": {
#             "44ee9403-4d88-4fd5-b998-2db8a611df67": {
#                 "start_time": {
#                     "current": "13:30",
#                     "original": "",
#                     "proposed": "14:30"
#                 }
#             }
#         }
#     }
#
# This object structure SHOULD be considered stable and MAY be used from other
# objects.
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
