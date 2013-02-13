class CreateInstrumentContext
  attr_reader :person
  attr_reader :response_set
  attr_reader :user

  def initialize(response_set, user)
    @response_set = response_set
    @user = user
  end

  def self.run(response_set)
    new(response_set).create
  end

  def create
    return if response_set.instrument_context

    load_data

    InstrumentContext.transaction do
      ctx = response_set.create_instrument_context
      populate(ctx)
      ctx.save
    end
  end

  def load_data
    if response_set.user_id
      @person = Person.with_contact_data.find(response_set.user_id)
    end
  end

  def populate(ctx)
    ctx.set 'interviewer_name', interviewer_name
    ctx.set 'p_full_name', p_full_name
    ctx.set 'p_dob', p_dob
  end

  def interviewer_name
    user.full_name || '[INTERVIEWER NAME]'
  end

  def p_full_name
    fn = person.try(:full_name)

    if fn.blank?
      '[UNKNOWN]'
    else
      fn
    end
  end

  def p_dob
    person.try(:person_dob) || '[UNKNOWN]'
  end
end
