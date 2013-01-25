# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class MMother < Base

    def reference_identifiers
      [
        "prepopulated_should_show_room_mold_child",
        "prepopulated_should_show_demographics",
        "prepopulated_is_prev_event_birth_li_and_set_to_complete"
      ]
    end

    ##
    # Set values in the most recent response set for the instrument
    def populate
      prepopulate_response_set(instrument.response_sets.last)
    end

    ##
    # Creates responses for questions with reference identifiers
    # that are known values and should be prepopulated
    # @param [ResponseSet]
    # @return [ResponseSet]
    def prepopulate_response_set(response_set)
      reference_identifiers.each do |reference_identifier|
        if question = find_question_for_reference_identifier(
                                              reference_identifier)
          response_type = "answer"
          answer =
            case reference_identifier
            when "prepopulated_should_show_room_mold_child"
              answer_for(question, is_response_to_mold_question_yes?)
            when "prepopulated_should_show_demographics"
              answer_for(question, were_there_prenatal_events?)
            when "prepopulated_is_prev_event_birth_li_and_set_to_complete"
              answer_for(question, does_completed_birth_record_exists?)
            else
              nil
            end
          build_response_for_value(response_type, response_set,
                                   question, answer, nil)
        end
      end
      response_set
    end

    def get_last_response_as_string(data_export_identifier)
      most_recent_response = person.responses_for(data_export_identifier).last
      most_recent_response.try(:answer).try(:reference_identifier)
    end

    def is_response_to_mold_question_yes?
      get_last_response_as_string(
                    "EIGHTEEN_MTH_MOTHER_2.MOLD") == NcsCode::YES.to_s
    end

    def were_there_prenatal_events?
      person.events.each do |event|
        return false unless Event::POSTNATAL_EVENTS.any? { |pnatal_event_code|
          event.event_type_code == pnatal_event_code
        }
      end

      true
    end

    def does_completed_birth_record_exists?
      ncs_code = NcsCode::for_list_name_and_local_code('EVENT_TYPE_CL1',
                                                       Event::birth_code)
      person.events.each do |event|
        if event.event_type_code == Event::birth_code
          return person.participant.completed_event?(ncs_code)
        end
      end

      false
    end

  end
end
