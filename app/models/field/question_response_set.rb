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
    include Enumerable

    attr_reader :responses
    attr_reader :changed
    attr_reader :errors

    def_delegators :responses, :blank?, :length, :each

    def initialize(*rs)
      @responses = Set.new
      @errors = ActiveModel::Errors.new(self)

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

      old_length = responses.length
      responses << wrap(response)
      @changed = responses.length != old_length
    end

    def public_id
      @question_id
    end

    ##
    # Marks all existing responses for destruction and inserts new responses
    # from another QuestionResponseSet.
    def patch(other)
      old = responses.dup
      new = Set.new

      other.each do |r|
        new << r unless old.include?(r)
      end

      return if new.empty?

      resolve_models

      responses.clear
      old.each { |r| r.mark_for_destruction }
      new.each { |r| self << r }
      old.each { |r| self << r }
    end

    ##
    # Saves and destroys responses.
    def save(options = {})
      ActiveRecord::Base.transaction do
        resolve_models

        ok = all? do |r|
          r.marked_for_destruction? ? r.destroy : r.save
        end

        if ok
          @changed = false
        else
          collect_errors
          raise ActiveRecord::Rollback
        end

        ok
      end
    end

    def collect_errors
      each do |r|
        errors.add(r.question_id, r.errors.to_a)
      end
    end

    def ==(other)
      other.respond_to?(:responses) && responses == other.responses
    end

    ##
    # QuestionResponseSets must be merged all-or-nothing.
    #
    # Required by the merge code.
    def merge_atomically?
      true
    end

    def to_model
      self
    end

    def resolve_models
      each(&:resolve_model)
    end

    ##
    # QuestionResponseSets are changed when responses are added to them via #<<
    # or #replace.  Their change state is reset on successful save.
    def changed?
      changed
    end

    ##
    # Wraps Responses in a comparable value object, or returns the input if
    # it's already wrapped.
    def wrap(r)
      return r if Response === r

      Response.new(r.question_id, r.answer_id, r.response_group, r.value).tap do |rf|
        rf.wrapped_response = r
      end
    end

    class Response < Struct.new(:question_id, :answer_id, :response_group, :value)
      extend Forwardable

      attr_accessor :wrapped_response
      attr_accessor :response_model

      def_delegators :response_model, :mark_for_destruction, :marked_for_destruction?, :save, :destroy, :errors

      def resolve_model
        self.response_model = wrapped_response.to_model
      end
    end
  end
end
