# -*- coding: utf-8 -*-

require 'bigdecimal'
require 'date'
require 'forwardable'
require 'ncs_navigator/core'

##
# These adapters were bootstrapped from the fieldwork JSON schema.
#
# Schema revision: 3a646300298ff48e1ac390283e3a6a6283893d47
module NcsNavigator::Core::Fieldwork::Adapters
  def adapt_hash(type, o)
    case type

    when :contact; ContactHashAdapter.new(o)

    when :event; EventHashAdapter.new(o)

    when :instrument; InstrumentHashAdapter.new(o)

    when :participant; ParticipantHashAdapter.new(o)

    when :person; PersonHashAdapter.new(o)

    when :response; ResponseHashAdapter.new(o)

    when :response_set; ResponseSetHashAdapter.new(o)

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

  module ActiveRecordTypeCoercion
    def date(x)
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

    def decimal(x)
      case x
      when BigDecimal; x
      when NilClass; x
      else BigDecimal.new(x)
      end
    end
  end

  class Adapter < Struct.new(:target, :ancestors)
    def initialize(*args)
      super

      self.ancestors = {}
    end

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end
  end

  class ContactModelAdapter < Adapter
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def contact_comment
      target.contact_comment
    end

    def contact_comment=(val)
      target.contact_comment = val
    end

    attr_accessible :contact_comment

    def contact_date_date
      target.contact_date_date
    end

    def contact_date_date=(val)
      target.contact_date_date = val
    end

    attr_accessible :contact_date_date

    def contact_id
      target.contact_id
    end

    def contact_id=(val)
      target.contact_id = val
    end

    attr_accessible :contact_id

    def contact_disposition
      target.contact_disposition
    end

    def contact_disposition=(val)
      target.contact_disposition = val
    end

    attr_accessible :contact_disposition

    def contact_distance
      target.contact_distance
    end

    def contact_distance=(val)
      target.contact_distance = val
    end

    attr_accessible :contact_distance

    def contact_end_time
      target.contact_end_time
    end

    def contact_end_time=(val)
      target.contact_end_time = val
    end

    attr_accessible :contact_end_time

    def contact_interpret_code
      target.contact_interpret_code
    end

    def contact_interpret_code=(val)
      target.contact_interpret_code = val
    end

    attr_accessible :contact_interpret_code

    def contact_interpret_other
      target.contact_interpret_other
    end

    def contact_interpret_other=(val)
      target.contact_interpret_other = val
    end

    attr_accessible :contact_interpret_other

    def contact_language_code
      target.contact_language_code
    end

    def contact_language_code=(val)
      target.contact_language_code = val
    end

    attr_accessible :contact_language_code

    def contact_language_other
      target.contact_language_other
    end

    def contact_language_other=(val)
      target.contact_language_other = val
    end

    attr_accessible :contact_language_other

    def contact_location_code
      target.contact_location_code
    end

    def contact_location_code=(val)
      target.contact_location_code = val
    end

    attr_accessible :contact_location_code

    def contact_location_other
      target.contact_location_other
    end

    def contact_location_other=(val)
      target.contact_location_other = val
    end

    attr_accessible :contact_location_other

    def contact_private_code
      target.contact_private_code
    end

    def contact_private_code=(val)
      target.contact_private_code = val
    end

    attr_accessible :contact_private_code

    def contact_private_detail
      target.contact_private_detail
    end

    def contact_private_detail=(val)
      target.contact_private_detail = val
    end

    attr_accessible :contact_private_detail

    def contact_start_time
      target.contact_start_time
    end

    def contact_start_time=(val)
      target.contact_start_time = val
    end

    attr_accessible :contact_start_time

    def contact_type_code
      target.contact_type_code
    end

    def contact_type_code=(val)
      target.contact_type_code = val
    end

    attr_accessible :contact_type_code

    def who_contacted_code
      target.who_contacted_code
    end

    def who_contacted_code=(val)
      target.who_contacted_code = val
    end

    attr_accessible :who_contacted_code

    def who_contacted_other
      target.who_contacted_other
    end

    def who_contacted_other=(val)
      target.who_contacted_other = val
    end

    attr_accessible :who_contacted_other

    def to_model
      self
    end

    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

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

    def patch(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def merge_atomically?
      false
    end

    def ==(other)
      target == other
    end
  end

  class ContactHashAdapter < Adapter
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def contact_comment
      (target[%q{contact_comment}])
    end

    def contact_comment=(val)
      target[%q{contact_comment}] = val
    end

    def contact_date_date
      date(target[%q{contact_date_date}])
    end

    def contact_date_date=(val)
      target[%q{contact_date_date}] = val
    end

    def contact_disposition
      (target[%q{contact_disposition}])
    end

    def contact_disposition=(val)
      target[%q{contact_disposition}] = val
    end

    def contact_distance
      decimal(target[%q{contact_distance}])
    end

    def contact_distance=(val)
      target[%q{contact_distance}] = val
    end

    def contact_end_time
      (target[%q{contact_end_time}])
    end

    def contact_end_time=(val)
      target[%q{contact_end_time}] = val
    end

    def contact_id
      (target[%q{contact_id}])
    end

    def contact_id=(val)
      target[%q{contact_id}] = val
    end

    def contact_interpret_code
      (target[%q{contact_interpret_code}])
    end

    def contact_interpret_code=(val)
      target[%q{contact_interpret_code}] = val
    end

    def contact_interpret_other
      (target[%q{contact_interpret_other}])
    end

    def contact_interpret_other=(val)
      target[%q{contact_interpret_other}] = val
    end

    def contact_language_code
      (target[%q{contact_language_code}])
    end

    def contact_language_code=(val)
      target[%q{contact_language_code}] = val
    end

    def contact_language_other
      (target[%q{contact_language_other}])
    end

    def contact_language_other=(val)
      target[%q{contact_language_other}] = val
    end

    def contact_location_code
      (target[%q{contact_location_code}])
    end

    def contact_location_code=(val)
      target[%q{contact_location_code}] = val
    end

    def contact_location_other
      (target[%q{contact_location_other}])
    end

    def contact_location_other=(val)
      target[%q{contact_location_other}] = val
    end

    def contact_private_code
      (target[%q{contact_private_code}])
    end

    def contact_private_code=(val)
      target[%q{contact_private_code}] = val
    end

    def contact_private_detail
      (target[%q{contact_private_detail}])
    end

    def contact_private_detail=(val)
      target[%q{contact_private_detail}] = val
    end

    def contact_start_time
      (target[%q{contact_start_time}])
    end

    def contact_start_time=(val)
      target[%q{contact_start_time}] = val
    end

    def contact_type_code
      (target[%q{contact_type_code}])
    end

    def contact_type_code=(val)
      target[%q{contact_type_code}] = val
    end

    def person_id
      (target[%q{person_id}])
    end

    def person_id=(val)
      target[%q{person_id}] = val
    end

    def version
      (target[%q{version}])
    end

    def version=(val)
      target[%q{version}] = val
    end

    def who_contacted_code
      (target[%q{who_contacted_code}])
    end

    def who_contacted_code=(val)
      target[%q{who_contacted_code}] = val
    end

    def who_contacted_other
      (target[%q{who_contacted_other}])
    end

    def who_contacted_other=(val)
      target[%q{who_contacted_other}] = val
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Contact.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class EventModelAdapter < Adapter
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def event_breakoff_code
      target.event_breakoff_code
    end

    def event_breakoff_code=(val)
      target.event_breakoff_code = val
    end

    attr_accessible :event_breakoff_code

    def event_comment
      target.event_comment
    end

    def event_comment=(val)
      target.event_comment = val
    end

    attr_accessible :event_comment

    def event_disposition
      target.event_disposition
    end

    def event_disposition=(val)
      target.event_disposition = val
    end

    attr_accessible :event_disposition

    def event_disposition_category_code
      target.event_disposition_category_code
    end

    def event_disposition_category_code=(val)
      target.event_disposition_category_code = val
    end

    attr_accessible :event_disposition_category_code

    def event_end_date
      target.event_end_date
    end

    def event_end_date=(val)
      target.event_end_date = val
    end

    attr_accessible :event_end_date

    def event_end_time
      target.event_end_time
    end

    def event_end_time=(val)
      target.event_end_time = val
    end

    attr_accessible :event_end_time

    def event_id
      target.event_id
    end

    def event_id=(val)
      target.event_id = val
    end

    attr_accessible :event_id

    def event_incentive_type_code
      target.event_incentive_type_code
    end

    def event_incentive_type_code=(val)
      target.event_incentive_type_code = val
    end

    attr_accessible :event_incentive_type_code

    def event_incentive_cash
      target.event_incentive_cash
    end

    def event_incentive_cash=(val)
      target.event_incentive_cash = val
    end

    attr_accessible :event_incentive_cash

    def event_repeat_key
      target.event_repeat_key
    end

    def event_repeat_key=(val)
      target.event_repeat_key = val
    end

    attr_accessible :event_repeat_key

    def event_start_date
      target.event_start_date
    end

    def event_start_date=(val)
      target.event_start_date = val
    end

    attr_accessible :event_start_date

    def event_start_time
      target.event_start_time
    end

    def event_start_time=(val)
      target.event_start_time = val
    end

    attr_accessible :event_start_time

    def event_type_code
      target.event_type_code
    end

    def event_type_code=(val)
      target.event_type_code = val
    end

    attr_accessible :event_type_code

    def event_type_other
      target.event_type_other
    end

    def event_type_other=(val)
      target.event_type_other = val
    end

    attr_accessible :event_type_other

    def to_model
      self
    end

    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

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

    def patch(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def merge_atomically?
      false
    end

    def ==(other)
      target == other
    end
  end

  class EventHashAdapter < Adapter
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def event_breakoff_code
      (target[%q{event_breakoff_code}])
    end

    def event_breakoff_code=(val)
      target[%q{event_breakoff_code}] = val
    end

    def event_comment
      (target[%q{event_comment}])
    end

    def event_comment=(val)
      target[%q{event_comment}] = val
    end

    def event_disposition
      (target[%q{event_disposition}])
    end

    def event_disposition=(val)
      target[%q{event_disposition}] = val
    end

    def event_disposition_category_code
      (target[%q{event_disposition_category_code}])
    end

    def event_disposition_category_code=(val)
      target[%q{event_disposition_category_code}] = val
    end

    def event_end_date
      date(target[%q{event_end_date}])
    end

    def event_end_date=(val)
      target[%q{event_end_date}] = val
    end

    def event_end_time
      (target[%q{event_end_time}])
    end

    def event_end_time=(val)
      target[%q{event_end_time}] = val
    end

    def event_id
      (target[%q{event_id}])
    end

    def event_id=(val)
      target[%q{event_id}] = val
    end

    def event_incentive_cash
      decimal(target[%q{event_incentive_cash}])
    end

    def event_incentive_cash=(val)
      target[%q{event_incentive_cash}] = val
    end

    def event_incentive_type_code
      (target[%q{event_incentive_type_code}])
    end

    def event_incentive_type_code=(val)
      target[%q{event_incentive_type_code}] = val
    end

    def event_repeat_key
      (target[%q{event_repeat_key}])
    end

    def event_repeat_key=(val)
      target[%q{event_repeat_key}] = val
    end

    def event_start_date
      date(target[%q{event_start_date}])
    end

    def event_start_date=(val)
      target[%q{event_start_date}] = val
    end

    def event_start_time
      (target[%q{event_start_time}])
    end

    def event_start_time=(val)
      target[%q{event_start_time}] = val
    end

    def event_type_code
      (target[%q{event_type_code}])
    end

    def event_type_code=(val)
      target[%q{event_type_code}] = val
    end

    def event_type_other
      (target[%q{event_type_other}])
    end

    def event_type_other=(val)
      target[%q{event_type_other}] = val
    end

    def name
      (target[%q{name}])
    end

    def name=(val)
      target[%q{name}] = val
    end

    def version
      (target[%q{version}])
    end

    def version=(val)
      target[%q{version}] = val
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Event.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class InstrumentModelAdapter < Adapter
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def instrument_breakoff_code
      target.instrument_breakoff_code
    end

    def instrument_breakoff_code=(val)
      target.instrument_breakoff_code = val
    end

    attr_accessible :instrument_breakoff_code

    def instrument_comment
      target.instrument_comment
    end

    def instrument_comment=(val)
      target.instrument_comment = val
    end

    attr_accessible :instrument_comment

    def data_problem_code
      target.data_problem_code
    end

    def data_problem_code=(val)
      target.data_problem_code = val
    end

    attr_accessible :data_problem_code

    def instrument_end_date
      target.instrument_end_date
    end

    def instrument_end_date=(val)
      target.instrument_end_date = val
    end

    attr_accessible :instrument_end_date

    def instrument_end_time
      target.instrument_end_time
    end

    def instrument_end_time=(val)
      target.instrument_end_time = val
    end

    attr_accessible :instrument_end_time

    def instrument_id
      target.instrument_id
    end

    def instrument_id=(val)
      target.instrument_id = val
    end

    attr_accessible :instrument_id

    def instrument_method_code
      target.instrument_method_code
    end

    def instrument_method_code=(val)
      target.instrument_method_code = val
    end

    attr_accessible :instrument_method_code

    def instrument_mode_code
      target.instrument_mode_code
    end

    def instrument_mode_code=(val)
      target.instrument_mode_code = val
    end

    attr_accessible :instrument_mode_code

    def instrument_mode_other
      target.instrument_mode_other
    end

    def instrument_mode_other=(val)
      target.instrument_mode_other = val
    end

    attr_accessible :instrument_mode_other

    def instrument_repeat_key
      target.instrument_repeat_key
    end

    def instrument_repeat_key=(val)
      target.instrument_repeat_key = val
    end

    attr_accessible :instrument_repeat_key

    def instrument_start_date
      target.instrument_start_date
    end

    def instrument_start_date=(val)
      target.instrument_start_date = val
    end

    attr_accessible :instrument_start_date

    def instrument_start_time
      target.instrument_start_time
    end

    def instrument_start_time=(val)
      target.instrument_start_time = val
    end

    attr_accessible :instrument_start_time

    def instrument_status_code
      target.instrument_status_code
    end

    def instrument_status_code=(val)
      target.instrument_status_code = val
    end

    attr_accessible :instrument_status_code

    def supervisor_review_code
      target.supervisor_review_code
    end

    def supervisor_review_code=(val)
      target.supervisor_review_code = val
    end

    attr_accessible :supervisor_review_code

    def instrument_type_code
      target.instrument_type_code
    end

    def instrument_type_code=(val)
      target.instrument_type_code = val
    end

    attr_accessible :instrument_type_code

    def instrument_type_other
      target.instrument_type_other
    end

    def instrument_type_other=(val)
      target.instrument_type_other = val
    end

    attr_accessible :instrument_type_other

    def to_model
      self
    end

    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

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

    def patch(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def merge_atomically?
      false
    end

    def ==(other)
      target == other
    end
  end

  class InstrumentHashAdapter < Adapter
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def data_problem_code
      (target[%q{data_problem_code}])
    end

    def data_problem_code=(val)
      target[%q{data_problem_code}] = val
    end

    def instrument_breakoff_code
      (target[%q{instrument_breakoff_code}])
    end

    def instrument_breakoff_code=(val)
      target[%q{instrument_breakoff_code}] = val
    end

    def instrument_comment
      (target[%q{instrument_comment}])
    end

    def instrument_comment=(val)
      target[%q{instrument_comment}] = val
    end

    def instrument_end_date
      date(target[%q{instrument_end_date}])
    end

    def instrument_end_date=(val)
      target[%q{instrument_end_date}] = val
    end

    def instrument_end_time
      (target[%q{instrument_end_time}])
    end

    def instrument_end_time=(val)
      target[%q{instrument_end_time}] = val
    end

    def instrument_id
      (target[%q{instrument_id}])
    end

    def instrument_id=(val)
      target[%q{instrument_id}] = val
    end

    def instrument_method_code
      (target[%q{instrument_method_code}])
    end

    def instrument_method_code=(val)
      target[%q{instrument_method_code}] = val
    end

    def instrument_mode_code
      (target[%q{instrument_mode_code}])
    end

    def instrument_mode_code=(val)
      target[%q{instrument_mode_code}] = val
    end

    def instrument_mode_other
      (target[%q{instrument_mode_other}])
    end

    def instrument_mode_other=(val)
      target[%q{instrument_mode_other}] = val
    end

    def instrument_repeat_key
      (target[%q{instrument_repeat_key}])
    end

    def instrument_repeat_key=(val)
      target[%q{instrument_repeat_key}] = val
    end

    def instrument_start_date
      date(target[%q{instrument_start_date}])
    end

    def instrument_start_date=(val)
      target[%q{instrument_start_date}] = val
    end

    def instrument_start_time
      (target[%q{instrument_start_time}])
    end

    def instrument_start_time=(val)
      target[%q{instrument_start_time}] = val
    end

    def instrument_status_code
      (target[%q{instrument_status_code}])
    end

    def instrument_status_code=(val)
      target[%q{instrument_status_code}] = val
    end

    def instrument_template_id
      (target[%q{instrument_template_id}])
    end

    def instrument_template_id=(val)
      target[%q{instrument_template_id}] = val
    end

    def instrument_type_code
      (target[%q{instrument_type_code}])
    end

    def instrument_type_code=(val)
      target[%q{instrument_type_code}] = val
    end

    def instrument_type_other
      (target[%q{instrument_type_other}])
    end

    def instrument_type_other=(val)
      target[%q{instrument_type_other}] = val
    end

    def instrument_version
      (target[%q{instrument_version}])
    end

    def instrument_version=(val)
      target[%q{instrument_version}] = val
    end

    def name
      (target[%q{name}])
    end

    def name=(val)
      target[%q{name}] = val
    end

    def response_set
      (target[%q{response_set}])
    end

    def response_set=(val)
      target[%q{response_set}] = val
    end

    def supervisor_review_code
      (target[%q{supervisor_review_code}])
    end

    def supervisor_review_code=(val)
      target[%q{supervisor_review_code}] = val
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Instrument.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class ParticipantModelAdapter < Adapter
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def to_model
      self
    end

    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

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

    def patch(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def merge_atomically?
      false
    end

    def ==(other)
      target == other
    end
  end

  class ParticipantHashAdapter < Adapter
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def p_id
      (target[%q{p_id}])
    end

    def p_id=(val)
      target[%q{p_id}] = val
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Participant.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class PersonModelAdapter < Adapter
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def to_model
      self
    end

    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

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

    def patch(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def merge_atomically?
      false
    end

    def ==(other)
      target == other
    end
  end

  class PersonHashAdapter < Adapter
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def cell_phone
      (target[%q{cell_phone}])
    end

    def cell_phone=(val)
      target[%q{cell_phone}] = val
    end

    def city
      (target[%q{city}])
    end

    def city=(val)
      target[%q{city}] = val
    end

    def email
      (target[%q{email}])
    end

    def email=(val)
      target[%q{email}] = val
    end

    def home_phone
      (target[%q{home_phone}])
    end

    def home_phone=(val)
      target[%q{home_phone}] = val
    end

    def name
      (target[%q{name}])
    end

    def name=(val)
      target[%q{name}] = val
    end

    def person_id
      (target[%q{person_id}])
    end

    def person_id=(val)
      target[%q{person_id}] = val
    end

    def relationship_code
      (target[%q{relationship_code}])
    end

    def relationship_code=(val)
      target[%q{relationship_code}] = val
    end

    def state
      (target[%q{state}])
    end

    def state=(val)
      target[%q{state}] = val
    end

    def street
      (target[%q{street}])
    end

    def street=(val)
      target[%q{street}] = val
    end

    def zip_code
      (target[%q{zip_code}])
    end

    def zip_code=(val)
      target[%q{zip_code}] = val
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Person.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class ResponseModelAdapter < Adapter
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def uuid
      target.api_id
    end

    def uuid=(val)
      target.api_id = val
    end

    attr_accessible :uuid

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

    def response_group
      target.response_group
    end

    def response_group=(val)
      target.response_group = val
    end

    attr_accessible :response_group

    def response_set_id
      target.response_set_id
    end

    def response_set_id=(val)
      target.response_set_id = val
    end

    attr_accessible :response_set_id

    def value
      target.value
    end

    def value=(val)
      target.value = val
    end

    attr_accessible :value

    def to_model
      self
    end

    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

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

    def patch(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def merge_atomically?
      false
    end

    def ==(other)
      target == other
    end
  end

  class ResponseHashAdapter < Adapter
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def answer_id
      (target[%q{answer_id}])
    end

    def answer_id=(val)
      target[%q{answer_id}] = val
    end

    def created_at
      (target[%q{created_at}])
    end

    def created_at=(val)
      target[%q{created_at}] = val
    end

    def question_id
      (target[%q{question_id}])
    end

    def question_id=(val)
      target[%q{question_id}] = val
    end

    def response_group
      (target[%q{response_group}])
    end

    def response_group=(val)
      target[%q{response_group}] = val
    end

    def updated_at
      (target[%q{updated_at}])
    end

    def updated_at=(val)
      target[%q{updated_at}] = val
    end

    def uuid
      (target[%q{uuid}])
    end

    def uuid=(val)
      target[%q{uuid}] = val
    end

    def value
      (target[%q{value}])
    end

    def value=(val)
      target[%q{value}] = val
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Response.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class ResponseSetModelAdapter < Adapter
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def to_model
      self
    end

    def as_json(options = nil)
      {}.tap do |h|
        self.class.accessible_attributes.each do |k|
          h[k] = send(k)
        end
      end
    end

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

    def patch(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def merge_atomically?
      false
    end

    def ==(other)
      target == other
    end
  end

  class ResponseSetHashAdapter < Adapter
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def completed_at
      (target[%q{completed_at}])
    end

    def completed_at=(val)
      target[%q{completed_at}] = val
    end

    def created_at
      (target[%q{created_at}])
    end

    def created_at=(val)
      target[%q{created_at}] = val
    end

    def survey_id
      (target[%q{survey_id}])
    end

    def survey_id=(val)
      target[%q{survey_id}] = val
    end

    def uuid
      (target[%q{uuid}])
    end

    def uuid=(val)
      target[%q{uuid}] = val
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(ResponseSet.new).tap do |m|
        m.ancestors = ancestors
        m.patch(target)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end
end
