require 'ncs_navigator/core'

module NcsNavigator::Core::Fieldwork
  ##
  # A merge strategy that unconditionally accepts proposed changes.
  #
  #
  # Affected entities
  # =================
  #
  # This algorithm affects the following entities:
  #
  # * contact data
  # * event data
  # * response sets
  # * responses
  #
  #
  # Merge semantics
  # ===============
  #
  # For each set of entities, there exists a map
  #
  #     entity ID => (original, current, proposed) = (O, C, P)
  #
  # This algorithm treats each set as described below.
  #
  # -> means "copies to", _ denotes "don't care".  Cases are loosely
  # describable as pattern-matching.
  #
  # Contact
  # -------
  #
  #     for each (_, C, P)
  #       P.contact_date -> C.contact_date_date
  #       P.start_time -> C.contact_start_time
  #       P.end_time -> C.contact_end_time
  #       P.disposition -> C.contact_disposition
  #
  #
  # Event
  # -----
  #
  #     for each (_, C, P)
  #       P.start_time -> C.event_start_time
  #       P.end_time -> C.event_end_time
  #       P.start_date -> C.event_start_date
  #       P.end_date -> C.event_end_date
  #       P.disposition -> C.event_disposition
  #       P.disposition_category -> C.event_disposition_category_code
  #
  #
  # Response set
  # ------------
  #
  # Context: an Instrument I
  #
  #     for each (O, C, P)
  #       case (O, C, P)
  #         # Case 1: C and P exist
  #         when (_, C, P)
  #           P.responses -> C.responses
  #
  #         # Case 2: C doesn't exist, P exists
  #         when (_, nil, P)
  #           C <- ResponseSet.new
  #           I.response_set <- C
  #
  #           P.responses -> C.responses
  #
  #
  # Responses (viz. P.responses -> C.responses)
  # -------------------------------------------
  #
  # Context: a ResponseSet RS
  #
  #     for each (O, C, P)
  #       case (O, C, P)
  #         # Case 1: C and P exist
  #         when (_, C, P)
  #           P.question_id -> C.question_id
  #           P.answer_id -> C.answer_id
  #
  #           cast P.value and store it in the appropriate field for C
  #
  #         # Case 2: C doesn't exist, P exists
  #         when (_, nil, P)
  #           C <- Response.new
  #           C.response_set <- RS
  #
  #           P.question_id -> C.question_id
  #           P.answer_id -> C.answer_id
  #
  #           cast P.value and store it in the appropriate field for C
  #
  module MergeTheirs
    attr_accessor :logger

    def merge
      merge_contacts
      merge_events
      merge_response_sets
      merge_responses
    end

    def save
      ActiveRecord::Base.transaction do
        [contacts, events, response_sets, responses].all? { |c| save_collection(c) }.tap do |res|
          unless res
            logger.fatal { 'Errors raised during save; rolling back' }
            raise ActiveRecord::Rollback
          end
        end
      end
    end

    module_function

    def merge_contacts
      for_each(contacts, 'contact') do |id, c, p|
        c.contact_date_date = parse_date(p['contact_date'])
        c.contact_disposition = p['disposition']
        c.contact_end_time = p['end_time']
        c.contact_start_time = p['start_time']
      end
    end

    def merge_events
      for_each(events, 'event') do |id, c, p|
        c.event_disposition = p['disposition']
        c.event_disposition_category_code = p['disposition_category'] if p['disposition_category']
        c.event_end_date = parse_date(p['end_date'])
        c.event_end_time = p['end_time']
        c.event_start_date = parse_date(p['start_date'])
        c.event_start_time = p['start_time']
      end
    end

    def merge_response_sets
      survey_ids = response_sets.select { |_, rs| rs[:proposed] }.map { |_, rs| rs[:proposed]['survey_id'] }.uniq
      surveys = Survey.where(:api_id => survey_ids).map { |s| [s.api_id, s] }.flatten
      instr_pairs = instruments.select { |_, instr| instr[:proposed] && instr[:current] }.map do |_, instr|
        [instr[:proposed]['response_set']['uuid'], instr[:current]]
      end.flatten

      instrument_for = Hash[*instr_pairs]
      survey_for = Hash[*surveys]

      new_response_sets = {}

      for_each(response_sets, 'response set', true) do |id, c, p|
        unless c
          new_response_sets[id] = ResponseSet.new.tap do |rs|
            rs.instrument = instrument_for[p['uuid']]
            rs.survey = survey_for[p['survey_id']]
          end
        end
      end

      new_response_sets.each do |id, rs|
        response_sets[id][:current] = rs
      end
    end

    def merge_responses
      vs = responses.select { |_, rs| rs[:proposed] }.map { |_, rs| [rs[:proposed]['answer_id'], rs[:proposed]['question_id']] }.uniq
      answer_ids = vs.map(&:first)
      question_ids = vs.map(&:last)

      answer_pairs = Answer.where(:api_id => answer_ids).map { |a| [a.api_id, a] }.flatten
      question_pairs = Question.where(:api_id => question_ids).map { |q| [q.api_id, q] }.flatten

      answers_for = Hash[*answer_pairs]
      questions_for = Hash[*question_pairs]

      m = response_sets.select { |_, rs| rs[:proposed]['responses'] && rs[:current] }
      response_set_for = {}

      m.each do |_, rs|
        rs[:proposed]['responses'].each do |r|
          response_set_for[r['uuid']] = rs[:current]
        end
      end

      new_responses = {}

      for_each(responses, 'response', true) do |id, c, p|
        if c
          merge_response(c, p, answers_for, questions_for)
        else
          new_responses[id] = Response.new.tap do |c|
            c.response_set = response_set_for[p['uuid']]

            merge_response(c, p, answers_for, questions_for)
          end
        end
      end

      new_responses.each do |id, r|
        responses[id][:current] = r
      end
    end

    def merge_response(c, p, answers_for, questions_for)
      c.answer = answers_for[p['answer_id']]
      c.question = questions_for[p['question_id']]
      c.unit = p['unit'] if p['unit']

      v = p['value']

      c.datetime_value = nil
      c.float_value = nil
      c.integer_value = nil
      c.string_value = nil
      c.text_value = nil

      return unless v

      if Integer === v
        c.integer_value = v
      end

      if Float === v
        c.float_value = v
      end

      begin
        c.datetime_value = Time.parse(v)
      rescue => e
      end

      sv = v.to_s

      if sv.length <= 255
        c.string_value = sv
      else
        c.text_value = sv
      end
    end

    def save_collection(c)
      c.all?  do |id, state|
        current = state[:current]

        if current
          current.save.tap do |ok|
            unless ok
              logger.error { "Errors raised saving #{current.name} #{current.id} (public ID: #{id}): #{current.errors.to_a.inspect}" }
            end
          end
        else
          true
        end
      end
    end

    def for_each(collection, type, missing_current_ok = false)
      collection.each do |k, c|
        current = c[:current]
        proposed = c[:proposed]

        logger.error { "Unable to find #{type} #{k}" } and next unless (current || missing_current_ok)

        yield k, current, proposed
      end
    end

    def parse_date(d)
      begin
        d ? Date.parse(d) : d
      rescue ArgumentError => e
        logger.error { %Q{Parsing date "#{d}" raised an error: #{e.message}"} }
        nil
      end
    end
  end
end
