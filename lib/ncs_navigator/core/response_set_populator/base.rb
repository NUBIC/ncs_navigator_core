# -*- coding: utf-8 -*-
require 'ncs_navigator/core'

module NcsNavigator::Core::ResponseSetPopulator
  class Base

    POPULATORS = [
      [/_ParticipantVerif_/,  ParticipantVerification],
      [/_Tracing_/,           TracingModule],
      [/_PBSamplingScreen_/,  PbsEligibilityScreener],
      [/_PregScreen_/,        PregnancyScreener],
    ]

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
      Base.populator_for(response_set).populate(self)
    end

    def self.populator_for(response_set)
      populator = POPULATORS.find { |instrument, handler| instrument =~ response_set.survey.title }
      populator ? populator[1] : TracingModule
    end

  end

  class InitializationError < StandardError; end

end