# -*- coding: utf-8 -*-

require 'bigdecimal'
require 'date'
require 'forwardable'
require 'ncs_navigator/core'

# These adapters provide a uniform interface over Cases' model objects and
# hashes from Field's datasets.
#
# The hash adapters also provide mechanisms for constructing models from
# hashes; see #to_model for more information.
#
# These adapters MUST be kept in sync with the fieldwork JSON schema.
module NcsNavigator::Core::Fieldwork::Adapters
  ##
  # Base class for all adapters.
  #
  # The adapter target is the adapted object; in this case, an ActiveRecord
  # model or hash.
  #
  # This class also defines [] and []= operators, which is useful to be able to
  # treat property access on models similarly to hashes.  (The merge code uses
  # this pretty heavily.)
  class Adapter < Struct.new(:target, :ancestors)
    include ActiveModel::MassAssignmentSecurity

    ##
    # Builds attribute accessors.
    #
    # The accessors defined by this method require that the adapter define the
    # following methods:
    #
    # * #set(attr, value)
    # * #get(attr)
    #
    # {HashBehavior} and {ModelBehavior} do this.
    def self.attr_accessors(attrs)
      attrs.each do |attr|
        to, from = case attr
                   when String; [attr, attr]
                   when Hash; attr.to_a.first
                   else raise "Invalid attribute spec #{attr.inspect}"
                   end

        define_method(to) { get(from) }
        define_method("#{to}=") { |v| set(from, v) }
        attr_accessible to
      end
    end

    def self.transform(attr, with)
      old = instance_method(attr)
      trans = instance_method(with)

      define_method(attr) do
        value = old.bind(self).call
        trans.bind(self).call(value)
      end
    end

    def initialize(*args)
      super

      self.ancestors ||= {}
    end

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end
  end

  ##
  # To avoid tedious unboxing code, we want to treat model adapters as
  # ActiveRecord objects.  This module lets us do so by implementing relevant
  # parts of the ActiveModel / ActiveRecord APIs.
  #
  # This module also includes code to build a whitelist of mergeable attributes.
  module ModelBehavior
    extend Forwardable

    def self.included(base)
      base.extend ActiveModel::Naming
    end

    ##
    # Used when generating a fieldwork set.
    #
    # @see Field::ScheduledActivityReport
    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

    def set(attr, value)
      target.send("#{attr}=", value)
    end

    def get(attr)
      target.send(attr)
    end

    ##
    # Applies changes to the wrapped model.
    def patch(attributes)
      sanitize_for_mass_assignment(attributes).each { |k, v| self[k] = v }
    end

    ##
    # Models can be merged on an attribute-by-attribute basis.
    def merge_atomically?
      false
    end

    def to_model
      self
    end

    # These methods are used in various field classes.
    def_delegators :target,
      :changed?,
      :destroy,
      :destroyed?,
      :errors,
      :mark_for_destruction,
      :marked_for_destruction?,
      :new_record?,
      :persisted?,
      :public_id,
      :save,
      :valid?
  end

  ##
  # Type coercions to make an attribute from a hash or an ActiveRecord model
  # be appropriate for an ActiveRecord model.
  module HashBehavior
    include NcsNavigator::Core::Fieldwork::Adapters

    def to_model
      adapt_model(model_class.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      target == other
    end

    def set(attr, value)
      target[attr] = value
    end

    def get(attr)
      target[attr]
    end

    def to_date(x)
      case x
      when Date; x
      when NilClass; x
      else
        begin
          Date.parse(x)
        rescue ArgumentError
        end
      end
    end

    def to_bigdecimal(x)
      case x
      when BigDecimal; x
      when NilClass; x
      else BigDecimal.new(x)
      end
    end
  end

  class ContactAdapter < Adapter
    attr_accessors %w(
      contact_comment
      contact_date_date
      contact_id
      contact_disposition
      contact_distance
      contact_end_time
      contact_interpret_code
      contact_interpret_other
      contact_language_code
      contact_language_other
      contact_location_code
      contact_location_other
      contact_private_code
      contact_private_detail
      contact_start_time
      contact_type_code
      who_contacted_code
      who_contacted_other
    )
  end

  class ContactModelAdapter < ContactAdapter
    include ModelBehavior
  end

  class ContactHashAdapter < ContactAdapter
    include HashBehavior

    transform :contact_date_date, :to_date
    transform :contact_distance, :to_bigdecimal

    def model_class
      ::Contact
    end
  end

  class EventAdapter < Adapter
    attr_accessors %w(
      event_breakoff_code
      event_comment
      event_disposition
      event_disposition_category_code
      event_end_date
      event_end_time
      event_id
      event_incentive_type_code
      event_incentive_cash
      event_repeat_key
      event_start_date
      event_start_time
      event_type_code
      event_type_other
      event_type_code
      event_type_other
    )
  end

  class EventModelAdapter < EventAdapter
    include ModelBehavior
  end

  class EventHashAdapter < EventAdapter
    include HashBehavior

    transform :event_end_date, :to_date
    transform :event_incentive_cash, :to_bigdecimal
    transform :event_start_date, :to_date

    def model_class
      ::Event
    end
  end

  class InstrumentAdapter < Adapter
    attr_accessors %w(
      data_problem_code
      instrument_breakoff_code
      instrument_comment
      instrument_end_date
      instrument_end_time
      instrument_id
      instrument_method_code
      instrument_mode_code
      instrument_mode_other
      instrument_repeat_key
      instrument_start_date
      instrument_start_time
      instrument_status_code
      instrument_type_code
      instrument_type_other
      supervisor_review_code
    )
  end

  class InstrumentModelAdapter < InstrumentAdapter
    include ModelBehavior
  end

  class InstrumentHashAdapter < InstrumentAdapter
    include HashBehavior

    transform :instrument_end_date, :to_date
    transform :instrument_start_date, :to_date

    def model_class
      ::Instrument
    end
  end

  class ParticipantModelAdapter < Adapter
    include ModelBehavior
  end

  class ParticipantHashAdapter < Adapter
    include HashBehavior

    attr_accessors %w(
      p_id
    )

    def model_class
      ::Participant
    end
  end

  class PersonAdapter < Adapter
    attr_accessors %w(
      first_name
      last_name
      middle_name
      person_id
      prefix_code
      suffix_code
    )
  end

  class PersonModelAdapter < PersonAdapter
    include ModelBehavior
  end

  class PersonHashAdapter < PersonAdapter
    include HashBehavior

    def model_class
      ::Person
    end
  end

  ##
  # Wraps response entities from Surveyor and Surveyor iOS.
  class ResponseModelAdapter < Adapter
    include ModelBehavior

    attr_accessors [
      { 'uuid' => 'api_id' },
      'response_group',
      'response_set_id',
      'value'
    ]

    def answer_id
      target.answer.try(:api_id)
    end

    def answer_id=(val)
      target.answer_id = Answer.where(:api_id => val).first.try(:id)
    end

    attr_accessible :answer_id

    def question_id
      target.question.try(:api_id)
    end

    def question_id=(val)
      target.question_id = Question.where(:api_id => val).first.try(:id)
    end

    attr_accessible :question_id
  end

  class ResponseHashAdapter < Adapter
    include HashBehavior

    attr_accessors %w(
      answer_id
      created_at
      question_id
      response_group
      updated_at
      uuid
      value
    )

    ##
    # Fills in Response#response_set_id.
    def to_model
      super.tap do |m|
        m.response_set_id = ResponseSet.where(:api_id => ancestors[:response_set].uuid).first.try(:id)
      end
    end

    def model_class
      ::Response
    end
  end

  class ResponseSetAdapter < Adapter
    attr_accessors %w(
      completed_at
      created_at
      p_id
      instrument_id
      survey_id
      uuid
    )
  end

  class ResponseSetModelAdapter < ResponseSetAdapter
    include ModelBehavior

    attr_accessors [
      { 'uuid' => 'api_id' }
    ]

    def survey_id
      target.survey.try(:api_id)
    end

    def survey_id=(val)
      target.survey_id = Survey.where(:api_id => val).first.try(:id)
    end

    attr_accessible :survey_id

    def p_id
      target.participant.try(:public_id)
    end

    def p_id=(val)
      target.participant_id = Participant.where(:p_id => val).first.try(:id)
    end

    attr_accessible :p_id

    def instrument_id
      target.instrument.try(:instrument_id)
    end

    def instrument_id=(val)
      target.instrument_id = Instrument.where(:instrument_id => val).first.try(:id)
    end

    attr_accessible :instrument_id
  end

  class ResponseSetHashAdapter < ResponseSetAdapter
    include HashBehavior

    def model_class
      ::ResponseSet
    end

    def to_model
      super.tap do |m|
        m.instrument_id = ancestors[:instrument].try(:instrument_id)
      end
    end
  end

  # Model adaptation methods.

  def adapt_hash(type, h)
    case type
    when :contact; ContactHashAdapter.new(h)
    when :event; EventHashAdapter.new(h)
    when :instrument; InstrumentHashAdapter.new(h)
    when :participant; ParticipantHashAdapter.new(h)
    when :person; PersonHashAdapter.new(h)
    when :response; ResponseHashAdapter.new(h)
    when :response_set; ResponseSetHashAdapter.new(h)
    end
  end

  def adapt_model(m)
    case m
    when Contact; ContactModelAdapter.new(m)
    when Event; EventModelAdapter.new(m)
    when Instrument; InstrumentModelAdapter.new(m)
    when Participant; ParticipantModelAdapter.new(m)
    when Person; PersonModelAdapter.new(m)
    when Response; ResponseModelAdapter.new(m)
    when ResponseSet; ResponseSetModelAdapter.new(m)
    end
  end
end
