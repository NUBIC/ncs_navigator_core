require 'ncs_navigator/core'

require 'forwardable'

module NcsNavigator::Core::Fieldwork
  ##
  # Groups responses by question ID.
  #
  # Mix this into a {Superposition} instance or anything with a compatible
  # entity map.
  module ResponseGrouping
    attr_accessor :response_groups

    def group_responses
      self.response_groups = {}.tap do |h|
        responses.each do |_, states|
          states.each do |state, response|
            qid = response.question_id

            unless h.has_key?(qid)
              h[qid] = {}
            end

            unless h[qid].has_key?(state)
              h[qid][state] = Group.new
            end

            h[qid][state] << response
          end
        end
      end
    end
  end

  ##
  # A Group defines an equivalence relation on a list of {Response}s.
  class Group
    extend Forwardable

    attr_accessor :responses

    def_delegators :responses, :<<, :length

    def initialize(responses = [])
      self.responses = responses
    end

    def question_id
      responses.first.try(&:question_id)
    end

    def ==(other)
      length == other.length && question_id == other.question_id
    end
  end
end
