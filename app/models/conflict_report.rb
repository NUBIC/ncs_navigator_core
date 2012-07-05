# -*- coding: utf-8 -*-

require 'forwardable'

##
# A value object for {Merge#conflict_report}.
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
#                 "contact_disposition": {
#                     "current": "0",
#                     "original": "-4",
#                     "proposed": "1"
#                 }
#             },
#             "ba8aa819-6bc3-4244-8cc5-1ed9d6201966": {
#                 "contact_language_code": {
#                     "current": "1",
#                     "original": "-4",
#                     "proposed": "2"
#                 }
#             }
#         },
#         "Event": {
#             "44ee9403-4d88-4fd5-b998-2db8a611df67": {
#                 "event_start_time": {
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
    return to_enum unless block_given?

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

  def to_enum
    Enumerator.new(self)
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

  # FIXME: Enumerator doesn't exist in 1.8.x.  When (if?) we become 1.9-only,
  # this needs to be removed.
  E = if RUBY_VERSION =~ /1\.8/
        Enumerable::Enumerator
      else
        ::Enumerator
      end

  ##
  # Extends Ruby's standard Enumerator with NCS code resolution.
  class Enumerator < E
    def initialize(obj)
      @obj = obj

      super
    end

    ##
    # Resolves NCS codes in the conflict report.
    #
    # NB: This method has to make a pass through the entire conflict report to
    # figure out which NCS codes to resolve, so be aware that using it in an
    # enumerator chain will cause at least two iterations through the report.
    def with_resolved_ncs_codes(&block)
      attributes = @obj.map { |_, as| as.map(&:name) }.flatten.uniq

      @code_table = NcsCode.for_attributes(*attributes).table
      @list_table = Hash[*attributes.map { |a| [a, NcsCode.attribute_lookup(a)] }.flatten]

      block_given? ? each(&block) : self
    end

    def each
      return self unless block_given?

      resolving = ncs_codes_loaded?

      super do |e, as|
        as.map! { |attr| resolve_code(attr) } if resolving

        yield e, as
      end
    end

    def ncs_codes_loaded?
      @code_table && @list_table
    end

    def resolve_code(attr)
      code_list = @list_table[attr.name]

      return attr unless code_list

      %w(current original proposed).each do |state|
        code = @code_table[code_list][attr.send(state).try(:to_i)]

        if code
          attr.send("#{state}=", code.to_s)
        end
      end

      attr
    end
  end
end
