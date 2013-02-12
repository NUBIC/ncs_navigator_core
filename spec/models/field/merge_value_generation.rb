# -*- coding: utf-8 -*-

require 'bigdecimal'
require 'date'
require 'facets/random'
require 'set'

module MergeValueGeneration
  DATES = (0...100).map { |x| Time.at(x.days).to_date }
  TIMES = (0...100).map { |x| Time.at(x.minutes) }
  MDES_TIMES = TIMES.map { |t| t.strftime("%H:%M") }

  ##
  # Generates random values appropriate for a property's type.
  #
  # Generated values are guaranteed unique across a single invocation of
  # gen_values.
  def gen_values(property, count)
    eclass = entity.constantize
    column = eclass.columns.detect { |c| c.name == property }
    raise "Unknown field #{entity}##{property}" unless column

    Set.new.tap do |gen|
      while gen.length < count
        value = case column.type
                when :date; DATES.at_rand
                when :decimal; BigDecimal.new((rand * 100).to_s)
                when :integer; rand(100)
                when :string, :text then
                  if property =~ /time\Z/
                    MDES_TIMES.at_rand
                  else
                    String.random
                  end
                when :datetime; TIMES.at_rand
                else raise "Cannot create a test value for #{entity}##{property} of type #{column.type.inspect}"
                end

        gen << value
      end
    end.to_a
  end
end
