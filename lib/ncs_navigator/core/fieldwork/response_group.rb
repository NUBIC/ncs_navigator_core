require 'ncs_navigator/core'

require 'forwardable'

module NcsNavigator::Core::Fieldwork
  ##
  # Groups {Response}s by their public question ID, and acts as a facade for
  # merge.
  class ResponseGroup < Struct.new(:responses)
    extend Forwardable

    def_delegators :responses, :<<, :length

    def initialize(*args)
      super

      self.responses ||= []
    end

    def question_id
      responses.first.try(&:question_id)
    end

    def =~(other)
      length == other.length && question_id == other.question_id
    end
  end
end
