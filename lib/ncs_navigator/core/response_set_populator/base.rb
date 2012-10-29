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
        response_set.responses.build(:question => question, :answer => answer)
      else
        response_set.responses.build(:question => question, :answer => answer, response_type.to_sym => value)
      end
    end

  end

  class InitializationError < StandardError; end

end