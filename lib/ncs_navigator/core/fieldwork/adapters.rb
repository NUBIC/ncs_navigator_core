require 'ncs_navigator/core'

##
# These adapters were bootstrapped from the fieldwork JSON schema.
#
# Schema revision: 4ffbaa28e32983d8dad3b333a9dbe8d509f2a174
module NcsNavigator::Core::Fieldwork::Adapters
  
  def adapt_contact(obj)
    case obj
    when ActiveRecord::Base; ContactModelAdapter.new(obj)
    when Hash; ContactHashAdapter.new(obj)
    else raise "No adapter known for #{obj.inspect}"
  end

  class ContactModelAdapter < Struct.new(:target)
    
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
    
    def end_time
    end

    def end_time=(val)
    end
    
    def person_id
    end

    def person_id=(val)
    end
    
    def start_time
    end

    def start_time=(val)
    end
    
    def type
    end

    def type=(val)
    end
    
  end

  class ContactHashAdapter < Struct.new(:target)
    
    def contact_date 
      target[%q{contact_date}]
    end

    def contact_date=(val)
      raise NotImplementedError
    end
    
    def contact_id 
      target[%q{contact_id}]
    end

    def contact_id=(val)
      raise NotImplementedError
    end
    
    def disposition 
      target[%q{disposition}]
    end

    def disposition=(val)
      raise NotImplementedError
    end
    
    def end_time 
      target[%q{end_time}]
    end

    def end_time=(val)
      raise NotImplementedError
    end
    
    def person_id 
      target[%q{person_id}]
    end

    def person_id=(val)
      raise NotImplementedError
    end
    
    def start_time 
      target[%q{start_time}]
    end

    def start_time=(val)
      raise NotImplementedError
    end
    
    def type 
      target[%q{type}]
    end

    def type=(val)
      raise NotImplementedError
    end
    
  end

  def adapt_event(obj)
    case obj
    when ActiveRecord::Base; EventModelAdapter.new(obj)
    when Hash; EventHashAdapter.new(obj)
    else raise "No adapter known for #{obj.inspect}"
  end

  class EventModelAdapter < Struct.new(:target)
    
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
    
    def name
    end

    def name=(val)
    end
    
    def start_date
    end

    def start_date=(val)
    end
    
    def start_time
    end

    def start_time=(val)
    end
    
  end

  class EventHashAdapter < Struct.new(:target)
    
    def disposition 
      target[%q{disposition}]
    end

    def disposition=(val)
      raise NotImplementedError
    end
    
    def disposition_category 
      target[%q{disposition_category}]
    end

    def disposition_category=(val)
      raise NotImplementedError
    end
    
    def end_date 
      target[%q{end_date}]
    end

    def end_date=(val)
      raise NotImplementedError
    end
    
    def end_time 
      target[%q{end_time}]
    end

    def end_time=(val)
      raise NotImplementedError
    end
    
    def event_id 
      target[%q{event_id}]
    end

    def event_id=(val)
      raise NotImplementedError
    end
    
    def name 
      target[%q{name}]
    end

    def name=(val)
      raise NotImplementedError
    end
    
    def start_date 
      target[%q{start_date}]
    end

    def start_date=(val)
      raise NotImplementedError
    end
    
    def start_time 
      target[%q{start_time}]
    end

    def start_time=(val)
      raise NotImplementedError
    end
    
  end

  def adapt_person(obj)
    case obj
    when ActiveRecord::Base; PersonModelAdapter.new(obj)
    when Hash; PersonHashAdapter.new(obj)
    else raise "No adapter known for #{obj.inspect}"
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
    
  end

  class PersonHashAdapter < Struct.new(:target)
    
    def cell_phone 
      target[%q{cell_phone}]
    end

    def cell_phone=(val)
      raise NotImplementedError
    end
    
    def city 
      target[%q{city}]
    end

    def city=(val)
      raise NotImplementedError
    end
    
    def email 
      target[%q{email}]
    end

    def email=(val)
      raise NotImplementedError
    end
    
    def home_phone 
      target[%q{home_phone}]
    end

    def home_phone=(val)
      raise NotImplementedError
    end
    
    def name 
      target[%q{name}]
    end

    def name=(val)
      raise NotImplementedError
    end
    
    def person_id 
      target[%q{person_id}]
    end

    def person_id=(val)
      raise NotImplementedError
    end
    
    def relationship_code 
      target[%q{relationship_code}]
    end

    def relationship_code=(val)
      raise NotImplementedError
    end
    
    def state 
      target[%q{state}]
    end

    def state=(val)
      raise NotImplementedError
    end
    
    def street 
      target[%q{street}]
    end

    def street=(val)
      raise NotImplementedError
    end
    
    def zip_code 
      target[%q{zip_code}]
    end

    def zip_code=(val)
      raise NotImplementedError
    end
    
  end

  def adapt_response(obj)
    case obj
    when ActiveRecord::Base; ResponseModelAdapter.new(obj)
    when Hash; ResponseHashAdapter.new(obj)
    else raise "No adapter known for #{obj.inspect}"
  end

  class ResponseModelAdapter < Struct.new(:target)
    
    def answer_id
    end

    def answer_id=(val)
    end
    
    def api_id
    end

    def api_id=(val)
    end
    
    def created_at
    end

    def created_at=(val)
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
    
  end

  class ResponseHashAdapter < Struct.new(:target)
    
    def answer_id 
      target[%q{answer_id}]
    end

    def answer_id=(val)
      raise NotImplementedError
    end
    
    def api_id 
      target[%q{api_id}]
    end

    def api_id=(val)
      raise NotImplementedError
    end
    
    def created_at 
      target[%q{created_at}]
    end

    def created_at=(val)
      raise NotImplementedError
    end
    
    def question_id 
      target[%q{question_id}]
    end

    def question_id=(val)
      raise NotImplementedError
    end
    
    def updated_at 
      target[%q{updated_at}]
    end

    def updated_at=(val)
      raise NotImplementedError
    end
    
    def value 
      target[%q{value}]
    end

    def value=(val)
      raise NotImplementedError
    end
    
  end

  def adapt_response_set(obj)
    case obj
    when ActiveRecord::Base; ResponseSetModelAdapter.new(obj)
    when Hash; ResponseSetHashAdapter.new(obj)
    else raise "No adapter known for #{obj.inspect}"
  end

  class ResponseSetModelAdapter < Struct.new(:target)
    
    def api_id
    end

    def api_id=(val)
    end
    
    def completed_at
    end

    def completed_at=(val)
    end
    
    def created_at
    end

    def created_at=(val)
    end
    
    def survey_id
    end

    def survey_id=(val)
    end
    
  end

  class ResponseSetHashAdapter < Struct.new(:target)
    
    def api_id 
      target[%q{api_id}]
    end

    def api_id=(val)
      raise NotImplementedError
    end
    
    def completed_at 
      target[%q{completed_at}]
    end

    def completed_at=(val)
      raise NotImplementedError
    end
    
    def created_at 
      target[%q{created_at}]
    end

    def created_at=(val)
      raise NotImplementedError
    end
    
    def survey_id 
      target[%q{survey_id}]
    end

    def survey_id=(val)
      raise NotImplementedError
    end
    
  end
end
