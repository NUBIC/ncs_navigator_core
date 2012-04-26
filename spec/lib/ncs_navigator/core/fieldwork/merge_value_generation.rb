# encoding: utf-8

require 'facets/random'
require 'set'

module MergeValueGeneration
  DATES = (Date.today - 100..Date.today).to_a

  ##
  # Generates random values appropriate for a property's type.
  #
  # Generated values are guaranteed unique across a single invocation of
  # gen_values.
  def gen_values(property, count)
    type = properties[property]['type']
    format = properties[property]['format'] || ''

    Set.new.tap do |gen|
      while gen.length < count
        gen << if type.include?('string')
                 if format.include?('date')
                   DATES.at_rand.to_s
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