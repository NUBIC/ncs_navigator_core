# encoding: utf-8

require 'ncs_navigator/core'

require 'forwardable'

module NcsNavigator::Core::Fieldwork
  ##
  # Groups {Response}s by their public question ID; also acts as a merge
  # façade.
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

    def changed?
      responses.any?(&:changed?)
    end

    def persisted?
      responses.all?(&:persisted?)
    end

    def to_model
      self.class.new(responses.map(&:to_model))
    end

    def =~(other)
      length == other.length && question_id == other.question_id
    end
  end
end
