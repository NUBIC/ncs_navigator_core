# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator

  class Base

    attr_accessor :person
    attr_accessor :survey
    attr_accessor :instrument
    attr_accessor :contact_link

    def initialize(*args)
      if args.length == 1 && args.first.respond_to?(:each_pair)
        super()

        args.first.each { |k, v| send("#{k}=", v) }
      else
        super
      end

      [:person, :instrument, :survey].each do |attr|
        raise InitializationError.new("No #{attr} provided") if send("#{attr}").blank?
      end

    end

    def event
      @event ||= self.contact_link.event if self.contact_link
    end

    def contact
      @contact ||= self.contact_link.contact if self.contact_link
    end

    def participant
      @participant ||= self.instrument.response_sets.last.try(:participant)
    end

    # To be implemented by subclasses
    def reference_identifiers
      []
    end

    def process
      Base.populator_for(survey).new(to_params).populate
    end

    def self.populator_for(survey)
      populator = POPULATORS.find { |instrument, handler| instrument =~ survey.title }
      populator ? populator[1] : TracingModule
    end

    def to_params
      {
        :person => person,
        :survey => survey,
        :instrument => instrument,
        :contact_link => contact_link
      }
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

    def valid_response_exists?(data_export_identifier)
      result = false
      if response = person.responses_for(data_export_identifier).first
        reference_identifier = response.try(:answer).try(:reference_identifier).to_s
        result = true unless %w(neg_1 neg_2).include?(reference_identifier)
      end
      result
    end

    def prepopulated_mode_of_contact(question)
      # If In-Person use 'capi' otherwise use 'cati'
      # TODO: how to determine 'papi' ?
      reference_identifier = contact.try(:contact_type_code) == 1 ? "capi" : "cati"
      question.answers.select { |a| a.reference_identifier == reference_identifier }.first
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