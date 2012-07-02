# -*- coding: utf-8 -*-


require 'ncs_navigator/core'

module NcsNavigator::Core::Fieldwork
  ##
  # A merge façade for {ResponseModelAdapter} and {ResponseHashAdapter}s.
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
      map_responses(&:answer_id)
    end

    ##
    # Assigns response set IDs to responses and saves responses.
    #
    # Response set IDs are derived from the #ancestors map on each adapter
    # instance.
    def save
      set_response_set_ids

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
      map_responses(&:value)
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

    def set_response_set_ids
      rs_uuid_map = map_responses { |r| r.ancestors[:response_set].uuid }
      response_sets = ResponseSet.where(:api_id => rs_uuid_map.values)
      rs_id_map = Hash[*response_sets.map { |rs| [rs.api_id, rs.id] }.flatten]

      responses.each do |uuid, r|
        rs_uuid = rs_uuid_map[uuid]

        r.response_set_id = rs_id_map[rs_uuid]
      end
    end

    private

    def map_responses
      {}.tap do |h|
        responses.each { |uuid, r| h[uuid] = yield r }
      end
    end
  end
end
