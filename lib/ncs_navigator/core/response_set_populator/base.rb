# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator

  class Base

    attr_accessor :person
    attr_accessor :survey
    attr_accessor :instrument
    attr_accessor :mode
    attr_accessor :event

    def initialize(person, instrument, survey, options = {})
      default_options = {
        :mode => Instrument.capi,
        :event => nil
      }.merge!(options)
      @person     = person
      @instrument = instrument
      @survey     = survey
      @mode       = default_options[:mode]
      @event      = default_options[:event]
      [:person, :instrument, :survey].each do |attr|
        raise InitializationError.new("No #{attr} provided") if send("#{attr}").blank?
      end
    end

    def participant
      @participant ||= self.instrument.response_sets.last.try(:participant)
    end

    # To be implemented by subclasses
    def reference_identifiers
      []
    end

    def process
      Base.populator_for(survey).new(person, instrument, survey, event, contact).populate
    end

    def self.populator_for(survey)
      populator = POPULATORS.find { |instrument, handler| instrument =~ survey.title }
      populator ? populator[1] : TracingModule
    end

    def find_question_for_reference_identifier(reference_identifier)
      question = nil
      survey.sections_with_questions.each do |section|
        section.questions.each do |q|
          question = q if q.reference_identifier == reference_identifier
          break unless question.nil?
        end
        break unless question.nil?
      end
      question
    end

    def build_response_for_value(response_type, response_set, question, answer, value)
      if response_type == "answer"
        return if answer.nil?
        response_set.responses.build(:question => question, :answer => answer)
      else
        return if value.nil?
        response_set.responses.build(:question => question, :answer => answer, response_type.to_sym => value)
      end
    end

    def valid_response_exists?(data_export_identifier, which_response = :first)
      result = false
      if response = person.responses_for(data_export_identifier).send(which_response)
        reference_identifier = response.try(:answer).try(:reference_identifier).to_s
        result = true unless %w(neg_1 neg_2).include?(reference_identifier)
      end
      result
    end

    ##
    # Determine if the mode of contact is CATI, CAPI, or PAPI
    # @return[Answer]
    def prepopulated_mode_of_contact(question)
      question.answers.select { |a| a.reference_identifier == mode_to_text }.first
    end

    ##
    # Translate the mode (an Integer) to a String. Used to determine
    # the Answer set in prepopulated_mode_of_contact
    # @return[String]
    def mode_to_text
      case mode
      when Instrument.papi
        'papi'
      when Instrument.cati
        'cati'
      when Instrument.capi
        'capi'
      else
        'capi'
      end
    end

    # Find the answer with the matching reference identifier for question
    # @param [Question]
    # @param [String] reference_identifier matching answer
    # @return [Answer]
    def answer_for(question, ri)
      question.answers.select { |a| a.reference_identifier == ri.to_s }.first
    end

  end

  class InitializationError < StandardError; end

end