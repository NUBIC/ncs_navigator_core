require 'ncs_navigator/core'

##
# These adapters were bootstrapped from the fieldwork JSON schema.
#
# Schema revision: d47b2ee9b71dd5e2002f0f19704648781433eb21
module NcsNavigator::Core::Fieldwork::Adapters
  def adapt_hash(type, o)
    case type
    when :contact; ContactHashAdapter.new(o)
    when :event; EventHashAdapter.new(o)
    when :person; PersonHashAdapter.new(o)
    when :response; ResponseHashAdapter.new(o)
    when :response_set; ResponseSetHashAdapter.new(o)

    end
  end

  def adapt_model(m)
    case m
    when Contact; ContactModelAdapter.new(m)
    when Event; EventModelAdapter.new(m)
    when Person; PersonModelAdapter.new(m)
    when Response; ResponseModelAdapter.new(m)
    when ResponseSet; ResponseSetModelAdapter.new(m)

    end
  end

  class ContactModelAdapter < Struct.new(:target)

    def comments
    end

    def comments=(val)
    end

    def contact_date
    end

    def contact_date=(val)
    end

    def contact_id
    end

    def contact_id=(val)
    end

    def disposition
    end

    def disposition=(val)
    end

    def distance_traveled
    end

    def distance_traveled=(val)
    end

    def end_time
    end

    def end_time=(val)
    end

    def interpreter
    end

    def interpreter=(val)
    end

    def interpreter_other
    end

    def interpreter_other=(val)
    end

    def language
    end

    def language=(val)
    end

    def language_other
    end

    def language_other=(val)
    end

    def location
    end

    def location=(val)
    end

    def location_other
    end

    def location_other=(val)
    end

    def person_id
    end

    def person_id=(val)
    end

    def private
    end

    def private=(val)
    end

    def private_detail
    end

    def private_detail=(val)
    end

    def start_time
    end

    def start_time=(val)
    end

    def type
    end

    def type=(val)
    end

    def who_contacted
    end

    def who_contacted=(val)
    end

    def who_contacted_other
    end

    def who_contacted_other=(val)
    end

    def to_model
      target
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class ContactHashAdapter < Struct.new(:target)

    def comments
      target[%q{comments}]
    end

    def contact_date
      target[%q{contact_date}]
    end

    def contact_id
      target[%q{contact_id}]
    end

    def disposition
      target[%q{disposition}]
    end

    def distance_traveled
      target[%q{distance_traveled}]
    end

    def end_time
      target[%q{end_time}]
    end

    def interpreter
      target[%q{interpreter}]
    end

    def interpreter_other
      target[%q{interpreter_other}]
    end

    def language
      target[%q{language}]
    end

    def language_other
      target[%q{language_other}]
    end

    def location
      target[%q{location}]
    end

    def location_other
      target[%q{location_other}]
    end

    def person_id
      target[%q{person_id}]
    end

    def private
      target[%q{private}]
    end

    def private_detail
      target[%q{private_detail}]
    end

    def start_time
      target[%q{start_time}]
    end

    def type
      target[%q{type}]
    end

    def who_contacted
      target[%q{who_contacted}]
    end

    def who_contacted_other
      target[%q{who_contacted_other}]
    end

    def to_hash
      target
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class EventModelAdapter < Struct.new(:target)

    def break_off
    end

    def break_off=(val)
    end

    def comments
    end

    def comments=(val)
    end

    def disposition
    end

    def disposition=(val)
    end

    def disposition_category
    end

    def disposition_category=(val)
    end

    def end_date
    end

    def end_date=(val)
    end

    def end_time
    end

    def end_time=(val)
    end

    def event_id
    end

    def event_id=(val)
    end

    def incentive
    end

    def incentive=(val)
    end

    def incentive_cash
    end

    def incentive_cash=(val)
    end

    def name
    end

    def name=(val)
    end

    def repeat_key
    end

    def repeat_key=(val)
    end

    def start_date
    end

    def start_date=(val)
    end

    def start_time
    end

    def start_time=(val)
    end

    def type
    end

    def type=(val)
    end

    def type_other
    end

    def type_other=(val)
    end

    def to_model
      target
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class EventHashAdapter < Struct.new(:target)

    def break_off
      target[%q{break_off}]
    end

    def comments
      target[%q{comments}]
    end

    def disposition
      target[%q{disposition}]
    end

    def disposition_category
      target[%q{disposition_category}]
    end

    def end_date
      target[%q{end_date}]
    end

    def end_time
      target[%q{end_time}]
    end

    def event_id
      target[%q{event_id}]
    end

    def incentive
      target[%q{incentive}]
    end

    def incentive_cash
      target[%q{incentive_cash}]
    end

    def name
      target[%q{name}]
    end

    def repeat_key
      target[%q{repeat_key}]
    end

    def start_date
      target[%q{start_date}]
    end

    def start_time
      target[%q{start_time}]
    end

    def type
      target[%q{type}]
    end

    def type_other
      target[%q{type_other}]
    end

    def to_hash
      target
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class PersonModelAdapter < Struct.new(:target)

    def cell_phone
    end

    def cell_phone=(val)
    end

    def city
    end

    def city=(val)
    end

    def email
    end

    def email=(val)
    end

    def home_phone
    end

    def home_phone=(val)
    end

    def name
    end

    def name=(val)
    end

    def person_id
    end

    def person_id=(val)
    end

    def relationship_code
    end

    def relationship_code=(val)
    end

    def state
    end

    def state=(val)
    end

    def street
    end

    def street=(val)
    end

    def zip_code
    end

    def zip_code=(val)
    end

    def to_model
      target
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class PersonHashAdapter < Struct.new(:target)

    def cell_phone
      target[%q{cell_phone}]
    end

    def city
      target[%q{city}]
    end

    def email
      target[%q{email}]
    end

    def home_phone
      target[%q{home_phone}]
    end

    def name
      target[%q{name}]
    end

    def person_id
      target[%q{person_id}]
    end

    def relationship_code
      target[%q{relationship_code}]
    end

    def state
      target[%q{state}]
    end

    def street
      target[%q{street}]
    end

    def zip_code
      target[%q{zip_code}]
    end

    def to_hash
      target
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class ResponseModelAdapter < Struct.new(:target)

    def answer_id
    end

    def answer_id=(val)
    end

    def created_at
    end

    def created_at=(val)
    end

    def entity_id
    end

    def entity_id=(val)
    end

    def question_id
    end

    def question_id=(val)
    end

    def updated_at
    end

    def updated_at=(val)
    end

    def value
    end

    def value=(val)
    end

    def to_model
      target
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class ResponseHashAdapter < Struct.new(:target)

    def answer_id
      target[%q{answer_id}]
    end

    def created_at
      target[%q{created_at}]
    end

    def entity_id
      target[%q{entity_id}]
    end

    def question_id
      target[%q{question_id}]
    end

    def updated_at
      target[%q{updated_at}]
    end

    def value
      target[%q{value}]
    end

    def to_hash
      target
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end

  class ResponseSetModelAdapter < Struct.new(:target)

    def completed_at
    end

    def completed_at=(val)
    end

    def created_at
    end

    def created_at=(val)
    end

    def entity_id
    end

    def entity_id=(val)
    end

    def survey_id
    end

    def survey_id=(val)
    end

    def to_model
      target
    end

    def ==(other)
      to_model == other.to_model
    end
  end

  class ResponseSetHashAdapter < Struct.new(:target)

    def completed_at
      target[%q{completed_at}]
    end

    def created_at
      target[%q{created_at}]
    end

    def entity_id
      target[%q{entity_id}]
    end

    def survey_id
      target[%q{survey_id}]
    end

    def to_hash
      target
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end
end
