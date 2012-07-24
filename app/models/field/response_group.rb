require 'forwardable'
require 'set'

module Field
  ##
  # This defines an equivalence class (by question ID) on Surveyor's {Response}
  # object.  It also provides code to compare two ResponseGroups for answer
  # equality and answer-and-value equality.
  #
  # ResponseGroup objects are designed to permit merging survey data with
  # {Merge}.
  #
  # The first response added to a ResponseGroup determines the question ID for
  # the ResponseGroup.  Attempts to add responses having different question IDs
  # will raise an error.
  class ResponseGroup
    extend Forwardable

    attr_reader :responses

    def_delegators :responses, :blank?, :length

    def initialize(*rs)
      @responses = Set.new

      rs.each { |r| self << r }
    end

    ##
    # Add a response.
    def <<(response)
      if responses.empty?
        @question_id = response.question_id
      end

      if @question_id != response.question_id
        raise "Cannot add a response with question ID #{response.question_id} to a ResponseGroup with question ID #{@question_id}"
      end

      responses << wrap(response)
    end

    def ==(other)
      responses == other.responses
    end

    ##
    # ResponseGroups must be merged all-or-nothing.
    def merge_atomically?
      true
    end

    ##
    # Wraps Responses in a comparable value object.
    def wrap(r)
      Response.new(r.question_id, r.answer_id, r.response_group, r.value).tap do |rf|
        rf.model = r
      end
    end

    class Response < Struct.new(:question_id, :answer_id, :response_group, :value)
      attr_accessor :model
    end
  end
end
