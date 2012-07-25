require 'forwardable'
require 'set'

module Field
  ##
  # This defines an equivalence class (by question ID) on Surveyor's {Response}
  # object.  It also provides code to compare two QuestionResponseSets for
  # answer equality and answer-and-value equality.
  #
  # QuestionResponseSet objects are designed to permit merging survey data with
  # {Merge}.
  #
  # The first response added to a QuestionResponseSet determines the question
  # ID for the QuestionResponseSet.  Attempts to add responses having different
  # question IDs will raise an error.
  class QuestionResponseSet
    extend Forwardable

    attr_reader :responses
    attr_reader :changed

    def_delegators :responses, :blank?, :length

    def initialize(*rs)
      @responses = Set.new

      rs.each { |r| self << r }

      @changed = false
    end

    ##
    # Add a response.
    def <<(response)
      if responses.empty?
        @question_id = response.question_id
      end

      if @question_id != response.question_id
        raise "Cannot add a response with question ID #{response.question_id} to a #{self.class.name} with question ID #{@question_id}"
      end

      responses << wrap(response)
      @changed = true
    end

    def ==(other)
      responses == other.responses
    end

    ##
    # QuestionResponseSets must be merged all-or-nothing.
    def merge_atomically?
      true
    end

    ##
    # QuestionResponseSets are changed when responses are added to them via #<<
    # or #replace.  Their change state is reset on successful save.
    def changed?
      changed
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
