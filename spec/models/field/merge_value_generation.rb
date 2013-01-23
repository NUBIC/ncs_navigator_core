# -*- coding: utf-8 -*-

require 'bigdecimal'
require 'date'
require 'facets/random'
require 'set'

module MergeValueGeneration
  DATES = (Date.today - 100..Date.today).to_a
  TIMES = (Time.now.to_i - 100..Time.now.to_i).map { |x| Time.at(x) }

  ##
  # Generates random values appropriate for a property's type.
  #
  # Generated values are guaranteed unique across a single invocation of
  # gen_values.
  def gen_values(property, count)
    type = properties[property]['type']
    format = properties[property]['format'] || ''
    pattern = properties[property]['pattern'] || ''

    Set.new.tap do |gen|
      while gen.length < count
        gen << if type.include?('string')
                 if pattern == "^(?:\\s*|\\d+|\\d+.\\d+)$"
                   BigDecimal.new((rand * 100).to_s)
                 elsif format.include?('date')
                   DATES.at_rand
                 # Our datetimes don't follow any predefined JSON Schema format.
                 elsif format == '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:Z|[+-]\\d{2}:\\d{2})'
                   TIMES.at_rand
                 else
                   String.random
                 end
               elsif type.include?('integer')
                 rand(100)
               else
                 raise "Cannot derive a test value for #{entity}##{property} of type #{type.inspect}"
               end
      end
    end.to_a
  end
end
