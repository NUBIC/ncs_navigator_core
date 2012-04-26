# encoding: utf-8

require 'ncs_navigator/core'

module NcsNavigator::Core::Fieldwork
  ##
  # A merge façade for {Response}s.
  #
  #
  # Assumptions
  # ===========
  #
  # It is the programmer's responsibility to ensure that every response added
  # to a response group has the same question ID.  See
  # {Superposition#group_responses} for an example of proper use.
  #
  #
  # Similarity
  # ==========
  #
  # Two response groups G1 and G2 are similar iff
  #
  # 1. they reference the same question,
  # 2. they have equal length (cardinality), and
  # 3. they contain the same public response IDs.
  class ResponseGroup
    attr_accessor :responses

    def initialize(responses = nil)
      self.responses = {}

      (responses || []).each { |r| self << r }
    end

    def <<(response)
      responses[response.uuid] = response
    end

    def length
      responses.length
    end

    def question_id
      responses.values.first.try(&:question_id)
    end

    def answer_ids
      responses.inject({}) { |h, (uuid, r)| h.update(uuid => r.answer_id) }
    end

    def save
      responses.all? { |_, v| v.save }
    end

    def answer_ids=(values)
      values.each do |k, answer_id|
        if (resp = responses[k])
          resp.answer_id = answer_id
        end
      end
    end

    def values
      responses.inject({}) { |h, (uuid, r)| h.update(uuid => r.value) }
    end

    def values=(values)
      values.each do |k, value|
        if (resp = responses[k])
          resp.value = value
        end
      end
    end

    def changed?
      responses.any? { |_, v| v.changed? }
    end

    def persisted?
      responses.all? { |_, v| v.persisted? }
    end

    def to_model
      self.class.new(responses.map { |_, v| v.to_model })
    end

    ##
    # For testing purposes.
    def ==(other)
      responses == other.responses
    end

    def =~(other)
      length == other.length &&
        question_id == other.question_id &&
        response_ids == other.response_ids
    end

    def response_ids
      responses.keys
    end
  end
end
