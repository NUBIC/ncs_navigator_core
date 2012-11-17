require 'logger'
require 'set'

module Psc
  ##
  # A set of scheduled activities from PSC implies the existence of the
  # following Cases models:
  #
  # * {ContactLink}
  # * {Contact}
  # * {Event}
  # * {Instrument}
  # * {InstrumentPlan}
  # * {Person}
  # * {Survey}
  #
  # This module contains code to generate intermediate representations of the
  # above models.  Its public interface is the single method {#derive_models}.
  #
  # Users of this module must respond to #activities with an enumerable that
  # yields {Psc::ScheduledActivity} objects.
  #
  # Intermediate representations are segregated by their type.  To transform
  # the IRs into actual Cases models, use {ModelReification#reify_models}.
  module ModelDerivation
    attr_reader :contact_links
    attr_reader :contacts
    attr_reader :events
    attr_reader :instruments
    attr_reader :instrument_plans
    attr_reader :people
    attr_reader :surveys

    def reset_collections
      @contact_links = Set.new
      @contacts = Set.new
      @events = Set.new
      @instruments = Set.new
      @instrument_plans = Set.new
      @people = Set.new
      @surveys = Set.new
    end

    def derive_models
      logger.info 'Derivation started'

      reset_collections

      activities.each do |activity|
        add_derived_entities_from_activity(activity)
      end

      plans = InstrumentPlanCollection.for(activities)

      plans.each do |plan|
        add_derived_entities_from_plan(plan)
      end

      log_derivations

      logger.info 'Derivation complete'
    end

    module_function

    def log_derivations
      return unless logger.level == ::Logger::DEBUG

      derivation_collections.each do |dc|
        dc.each do |entity|
          logger.debug { "Derived #{entity.inspect} from PSC schedule" }
        end
      end
    end

    def derivation_collections
      [contact_links, contacts, events, instruments, instrument_plans, people, surveys]
    end

    def add_derived_entities_from_activity(activity)
      activity.derive_implied_entities

      people << activity.person
      contacts << activity.contact
      events << activity.event
      contact_links << activity.contact_link
    end

    def add_derived_entities_from_plan(plan)
      instruments << plan.root
      instrument_plans << plan

      plan.surveys.each { |s| surveys << s }
    end
  end
end
