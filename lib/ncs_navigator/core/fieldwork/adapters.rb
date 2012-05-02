# -*- coding: utf-8 -*-

require 'bigdecimal'
require 'date'
require 'forwardable'
require 'ncs_navigator/core'

##
# These adapters were bootstrapped from the fieldwork JSON schema.
#
# Schema revision: af5edcc2cd0147814070f51ad38d0a7eeb49bc14
module NcsNavigator::Core::Fieldwork::Adapters
  def adapt_hash(type, o)
    case type

    when :contact; ContactHashAdapter.new(o)

    when :event; EventHashAdapter.new(o)

    when :instrument; InstrumentHashAdapter.new(o)

    when :response; ResponseHashAdapter.new(o)

    when :response_set; ResponseSetHashAdapter.new(o)

    end
  end

  def adapt_model(m)
    case m

    when Contact; ContactModelAdapter.new(m)

    when Event; EventModelAdapter.new(m)

    when Instrument; InstrumentModelAdapter.new(m)

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
      BigDecimal.new(x) if x
    end
  end

  class ContactModelAdapter < Struct.new(:target)
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def comments
      target.contact_comment
    end

    def comments=(val)
      target.contact_comment = val
    end

    attr_accessible :comments

    def contact_date
      target.contact_date
    end

    def contact_date=(val)
      target.contact_date = val
    end

    attr_accessible :contact_date

    def contact_id
      target.contact_id
    end

    def contact_id=(val)
      target.contact_id = val
    end

    attr_accessible :contact_id

    def disposition
      target.contact_disposition
    end

    def disposition=(val)
      target.contact_disposition = val
    end

    attr_accessible :disposition

    def distance_traveled
      target.contact_distance
    end

    def distance_traveled=(val)
      target.contact_distance = val
    end

    attr_accessible :distance_traveled

    def end_time
      target.contact_end_time
    end

    def end_time=(val)
      target.contact_end_time = val
    end

    attr_accessible :end_time

    def interpreter
      target.contact_interpret_code
    end

    def interpreter=(val)
      target.contact_interpret_code = val
    end

    attr_accessible :interpreter

    def interpreter_other
      target.contact_interpret_other
    end

    def interpreter_other=(val)
      target.contact_interpret_other = val
    end

    attr_accessible :interpreter_other

    def language
      target.contact_language_code
    end

    def language=(val)
      target.contact_language_code = val
    end

    attr_accessible :language

    def language_other
      target.contact_language_other
    end

    def language_other=(val)
      target.contact_language_other = val
    end

    attr_accessible :language_other

    def location
      target.contact_location_code
    end

    def location=(val)
      target.contact_location_code = val
    end

    attr_accessible :location

    def location_other
      target.contact_location_other
    end

    def location_other=(val)
      target.contact_location_other = val
    end

    attr_accessible :location_other

    def private
      target.contact_private_code
    end

    def private=(val)
      target.contact_private_code = val
    end

    attr_accessible :private

    def private_detail
      target.contact_private_detail
    end

    def private_detail=(val)
      target.contact_private_detail = val
    end

    attr_accessible :private_detail

    def start_time
      target.contact_start_time
    end

    def start_time=(val)
      target.contact_start_time = val
    end

    attr_accessible :start_time

    def type
      target.contact_type_code
    end

    def type=(val)
      target.contact_type_code = val
    end

    attr_accessible :type

    def who_contacted
      target.who_contacted_code
    end

    def who_contacted=(val)
      target.who_contacted_code = val
    end

    attr_accessible :who_contacted

    def who_contacted_other
      target.who_contacted_other
    end

    def who_contacted_other=(val)
      target.who_contacted_other = val
    end

    attr_accessible :who_contacted_other

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_model
      target
    end

    def_delegators :to_model, :persisted?, :new_record?, :valid?, :destroyed?, :errors, :changed?, :save, :public_id

    def attributes=(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class ContactHashAdapter < Struct.new(:target)
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def comments
      (target[%q{comments}])
    end

    def comments=(val)
      target[%q{comments}] = val
    end

    def contact_date
      date(target[%q{contact_date}])
    end

    def contact_date=(val)
      target[%q{contact_date}] = val
    end

    def contact_id
      (target[%q{contact_id}])
    end

    def contact_id=(val)
      target[%q{contact_id}] = val
    end

    def disposition
      (target[%q{disposition}])
    end

    def disposition=(val)
      target[%q{disposition}] = val
    end

    def distance_traveled
      decimal(target[%q{distance_traveled}])
    end

    def distance_traveled=(val)
      target[%q{distance_traveled}] = val
    end

    def end_time
      (target[%q{end_time}])
    end

    def end_time=(val)
      target[%q{end_time}] = val
    end

    def interpreter
      (target[%q{interpreter}])
    end

    def interpreter=(val)
      target[%q{interpreter}] = val
    end

    def interpreter_other
      (target[%q{interpreter_other}])
    end

    def interpreter_other=(val)
      target[%q{interpreter_other}] = val
    end

    def language
      (target[%q{language}])
    end

    def language=(val)
      target[%q{language}] = val
    end

    def language_other
      (target[%q{language_other}])
    end

    def language_other=(val)
      target[%q{language_other}] = val
    end

    def location
      (target[%q{location}])
    end

    def location=(val)
      target[%q{location}] = val
    end

    def location_other
      (target[%q{location_other}])
    end

    def location_other=(val)
      target[%q{location_other}] = val
    end

    def person_id
      (target[%q{person_id}])
    end

    def person_id=(val)
      target[%q{person_id}] = val
    end

    def private
      (target[%q{private}])
    end

    def private=(val)
      target[%q{private}] = val
    end

    def private_detail
      (target[%q{private_detail}])
    end

    def private_detail=(val)
      target[%q{private_detail}] = val
    end

    def start_time
      (target[%q{start_time}])
    end

    def start_time=(val)
      target[%q{start_time}] = val
    end

    def type
      (target[%q{type}])
    end

    def type=(val)
      target[%q{type}] = val
    end

    def version
      (target[%q{version}])
    end

    def version=(val)
      target[%q{version}] = val
    end

    def who_contacted
      (target[%q{who_contacted}])
    end

    def who_contacted=(val)
      target[%q{who_contacted}] = val
    end

    def who_contacted_other
      (target[%q{who_contacted_other}])
    end

    def who_contacted_other=(val)
      target[%q{who_contacted_other}] = val
    end

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Contact.new).tap { |m| m.attributes = target }
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class EventModelAdapter < Struct.new(:target)
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def break_off
      target.event_breakoff_code
    end

    def break_off=(val)
      target.event_breakoff_code = val
    end

    attr_accessible :break_off

    def comments
      target.event_comment
    end

    def comments=(val)
      target.event_comment = val
    end

    attr_accessible :comments

    def disposition
      target.event_disposition
    end

    def disposition=(val)
      target.event_disposition = val
    end

    attr_accessible :disposition

    def disposition_category
      target.event_disposition_category_code
    end

    def disposition_category=(val)
      target.event_disposition_category_code = val
    end

    attr_accessible :disposition_category

    def end_date
      target.event_end_date
    end

    def end_date=(val)
      target.event_end_date = val
    end

    attr_accessible :end_date

    def end_time
      target.event_end_time
    end

    def end_time=(val)
      target.event_end_time = val
    end

    attr_accessible :end_time

    def event_id
      target.event_id
    end

    def event_id=(val)
      target.event_id = val
    end

    attr_accessible :event_id

    def incentive_cash
      target.event_incentive_cash
    end

    def incentive_cash=(val)
      target.event_incentive_cash = val
    end

    attr_accessible :incentive_cash

    def incentive_type
      target.event_incentive_type_code
    end

    def incentive_type=(val)
      target.event_incentive_type_code = val
    end

    attr_accessible :incentive_type

    def repeat_key
      target.event_repeat_key
    end

    def repeat_key=(val)
      target.event_repeat_key = val
    end

    attr_accessible :repeat_key

    def start_date
      target.event_start_date
    end

    def start_date=(val)
      target.event_start_date = val
    end

    attr_accessible :start_date

    def start_time
      target.event_start_time
    end

    def start_time=(val)
      target.event_start_time = val
    end

    attr_accessible :start_time

    def type
      target.event_type_code
    end

    def type=(val)
      target.event_type_code = val
    end

    attr_accessible :type

    def type_other
      target.event_type_other
    end

    def type_other=(val)
      target.event_type_other = val
    end

    attr_accessible :type_other

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_model
      target
    end

    def_delegators :to_model, :persisted?, :new_record?, :valid?, :destroyed?, :errors, :changed?, :save, :public_id

    def attributes=(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class EventHashAdapter < Struct.new(:target)
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def break_off
      (target[%q{break_off}])
    end

    def break_off=(val)
      target[%q{break_off}] = val
    end

    def comments
      (target[%q{comments}])
    end

    def comments=(val)
      target[%q{comments}] = val
    end

    def disposition
      (target[%q{disposition}])
    end

    def disposition=(val)
      target[%q{disposition}] = val
    end

    def disposition_category
      (target[%q{disposition_category}])
    end

    def disposition_category=(val)
      target[%q{disposition_category}] = val
    end

    def end_date
      date(target[%q{end_date}])
    end

    def end_date=(val)
      target[%q{end_date}] = val
    end

    def end_time
      (target[%q{end_time}])
    end

    def end_time=(val)
      target[%q{end_time}] = val
    end

    def event_id
      (target[%q{event_id}])
    end

    def event_id=(val)
      target[%q{event_id}] = val
    end

    def incentive_cash
      decimal(target[%q{incentive_cash}])
    end

    def incentive_cash=(val)
      target[%q{incentive_cash}] = val
    end

    def incentive_type
      (target[%q{incentive_type}])
    end

    def incentive_type=(val)
      target[%q{incentive_type}] = val
    end

    def name
      (target[%q{name}])
    end

    def name=(val)
      target[%q{name}] = val
    end

    def repeat_key
      (target[%q{repeat_key}])
    end

    def repeat_key=(val)
      target[%q{repeat_key}] = val
    end

    def start_date
      date(target[%q{start_date}])
    end

    def start_date=(val)
      target[%q{start_date}] = val
    end

    def start_time
      (target[%q{start_time}])
    end

    def start_time=(val)
      target[%q{start_time}] = val
    end

    def type
      (target[%q{type}])
    end

    def type=(val)
      target[%q{type}] = val
    end

    def type_other
      (target[%q{type_other}])
    end

    def type_other=(val)
      target[%q{type_other}] = val
    end

    def version
      (target[%q{version}])
    end

    def version=(val)
      target[%q{version}] = val
    end

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Event.new).tap { |m| m.attributes = target }
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class InstrumentModelAdapter < Struct.new(:target)
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def breakoff
      target.instrument_breakoff_code
    end

    def breakoff=(val)
      target.instrument_breakoff_code = val
    end

    attr_accessible :breakoff

    def comments
      target.instrument_comment
    end

    def comments=(val)
      target.instrument_comment = val
    end

    attr_accessible :comments

    def data_problem
      target.data_problem_code
    end

    def data_problem=(val)
      target.data_problem_code = val
    end

    attr_accessible :data_problem

    def end_date
      target.instrument_end_date
    end

    def end_date=(val)
      target.instrument_end_date = val
    end

    attr_accessible :end_date

    def end_time
      target.instrument_end_time
    end

    def end_time=(val)
      target.instrument_end_time = val
    end

    attr_accessible :end_time

    def instrument_id
      target.instrument_id
    end

    def instrument_id=(val)
      target.instrument_id = val
    end

    attr_accessible :instrument_id

    def method_administered
      target.instrument_method_code
    end

    def method_administered=(val)
      target.instrument_method_code = val
    end

    attr_accessible :method_administered

    def mode_administered
      target.instrument_mode_code
    end

    def mode_administered=(val)
      target.instrument_mode_code = val
    end

    attr_accessible :mode_administered

    def mode_administered_other
      target.instrument_mode_other
    end

    def mode_administered_other=(val)
      target.instrument_mode_other = val
    end

    attr_accessible :mode_administered_other

    def repeat_key
      target.instrument_repeat_key
    end

    def repeat_key=(val)
      target.instrument_repeat_key = val
    end

    attr_accessible :repeat_key

    def start_date
      target.instrument_start_date
    end

    def start_date=(val)
      target.instrument_start_date = val
    end

    attr_accessible :start_date

    def start_time
      target.instrument_start_time
    end

    def start_time=(val)
      target.instrument_start_time = val
    end

    attr_accessible :start_time

    def status
      target.instrument_status_code
    end

    def status=(val)
      target.instrument_status_code = val
    end

    attr_accessible :status

    def supervisor_review
      target.supervisor_review_code
    end

    def supervisor_review=(val)
      target.supervisor_review_code = val
    end

    attr_accessible :supervisor_review

    def type
      target.instrument_type_code
    end

    def type=(val)
      target.instrument_type_code = val
    end

    attr_accessible :type

    def type_other
      target.instrument_type_other
    end

    def type_other=(val)
      target.instrument_type_other = val
    end

    attr_accessible :type_other

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_model
      target
    end

    def_delegators :to_model, :persisted?, :new_record?, :valid?, :destroyed?, :errors, :changed?, :save, :public_id

    def attributes=(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class InstrumentHashAdapter < Struct.new(:target)
    include NcsNavigator::Core::Fieldwork::Adapters
    include ActiveRecordTypeCoercion

    def breakoff
      (target[%q{breakoff}])
    end

    def breakoff=(val)
      target[%q{breakoff}] = val
    end

    def comments
      (target[%q{comments}])
    end

    def comments=(val)
      target[%q{comments}] = val
    end

    def data_problem
      (target[%q{data_problem}])
    end

    def data_problem=(val)
      target[%q{data_problem}] = val
    end

    def end_date
      date(target[%q{end_date}])
    end

    def end_date=(val)
      target[%q{end_date}] = val
    end

    def end_time
      (target[%q{end_time}])
    end

    def end_time=(val)
      target[%q{end_time}] = val
    end

    def instrument_id
      (target[%q{instrument_id}])
    end

    def instrument_id=(val)
      target[%q{instrument_id}] = val
    end

    def instrument_template_id
      (target[%q{instrument_template_id}])
    end

    def instrument_template_id=(val)
      target[%q{instrument_template_id}] = val
    end

    def instrument_version
      (target[%q{instrument_version}])
    end

    def instrument_version=(val)
      target[%q{instrument_version}] = val
    end

    def method_administered
      (target[%q{method_administered}])
    end

    def method_administered=(val)
      target[%q{method_administered}] = val
    end

    def mode_administered
      (target[%q{mode_administered}])
    end

    def mode_administered=(val)
      target[%q{mode_administered}] = val
    end

    def mode_administered_other
      (target[%q{mode_administered_other}])
    end

    def mode_administered_other=(val)
      target[%q{mode_administered_other}] = val
    end

    def name
      (target[%q{name}])
    end

    def name=(val)
      target[%q{name}] = val
    end

    def repeat_key
      (target[%q{repeat_key}])
    end

    def repeat_key=(val)
      target[%q{repeat_key}] = val
    end

    def response_set
      (target[%q{response_set}])
    end

    def response_set=(val)
      target[%q{response_set}] = val
    end

    def start_date
      date(target[%q{start_date}])
    end

    def start_date=(val)
      target[%q{start_date}] = val
    end

    def start_time
      (target[%q{start_time}])
    end

    def start_time=(val)
      target[%q{start_time}] = val
    end

    def status
      (target[%q{status}])
    end

    def status=(val)
      target[%q{status}] = val
    end

    def supervisor_review
      (target[%q{supervisor_review}])
    end

    def supervisor_review=(val)
      target[%q{supervisor_review}] = val
    end

    def type
      (target[%q{type}])
    end

    def type=(val)
      target[%q{type}] = val
    end

    def type_other
      (target[%q{type_other}])
    end

    def type_other=(val)
      target[%q{type_other}] = val
    end

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Instrument.new).tap { |m| m.attributes = target }
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class ResponseModelAdapter < Struct.new(:target)
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def answer_id
      target.answer.try(:api_id)
    end

    def answer_id=(val)
      target.answer = Answer.where(:api_id => val).first
    end

    attr_accessible :answer_id

    def question_id
      target.question.try(:api_id)
    end

    def question_id=(val)
      target.question = Question.where(:api_id => val).first
    end

    attr_accessible :question_id

    def uuid
      target.api_id
    end

    def value
      target.value
    end

    def value=(val)
      target.value = val
    end

    attr_accessible :value

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_model
      target
    end

    def_delegators :to_model, :persisted?, :new_record?, :valid?, :destroyed?, :errors, :changed?, :save, :public_id

    def attributes=(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class ResponseHashAdapter < Struct.new(:target)
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

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(Response.new).tap { |m| m.attributes = target }
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class ResponseSetModelAdapter < Struct.new(:target)
    extend Forwardable
    extend ActiveModel::Naming
    include ActiveModel::MassAssignmentSecurity

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_model
      target
    end

    def_delegators :to_model, :persisted?, :new_record?, :valid?, :destroyed?, :errors, :changed?, :save, :public_id

    def attributes=(target)
      sanitize_for_mass_assignment(target).each { |k, v| send("#{k}=", v) }
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class ResponseSetHashAdapter < Struct.new(:target)
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

    def [](a)
      send(a)
    end

    def []=(a, v)
      send("#{a}=", v)
    end

    def to_hash
      target
    end

    def to_model
      adapt_model(ResponseSet.new).tap { |m| m.attributes = target }
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end
end
