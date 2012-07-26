class ScheduledActivity
  include Comparable

  attr_accessor :study_segment, :activity_id, :current_state, :ideal_date, :date, :activity_name, :activity_type, :labels, :person_id
  attr_accessor :event, :instrument, :order, :participant_type, :collection, :mode, :references

  def initialize(attrs={})
    attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    parse_labels if @labels
  end

  ##
  # Extract data from the labels
  # and set as attributes on self
  def parse_labels
    @labels.split.each do |lbl|
      vals = lbl.split(':')
      self.send("#{vals.first}=", vals.last)
    end
  end
  private :parse_labels

  ##
  # Override ==
  # Checking attribute equality not object equality
  # @param [ScheduledActivity]
  # @return [Boolean]
  def ==(other)
    return false unless other.is_a? ScheduledActivity
    result = true
    self.instance_variable_names.each do |v|
      key = v.sub('@','')
      result = self.send("#{key}") == other.send("#{key}")
    end
    result
  end

  ##
  # Sorting, first by order then by person
  # -1, 0, or +1 depending on whether the receiver is
  # less than, equal to, or greater than the other object
  #
  # @return Integer
  def <=>(other)
    self.comparison_criteria <=> other.comparison_criteria
  end

  ##
  # Order & person.created_at
  # @return [Array<String,String>]
  def comparison_criteria
    [self.order.to_s, self.instrument.to_s, self.participant.try(:p_id)]
  end

  ##
  # True if activity_type includes 'Consent'
  # @return [Boolean]
  def consent_activity?
    @activity_type.to_s.include? "Consent"
  end

  ##
  # Set the participant for this activity
  #
  # @param Participant
  def participant=(part)
    @participant = part
  end

  ##
  # Return the @participant or the participant associated with the person
  # having the @person_id attribute
  #
  # @return Participant
  def participant
    @participant || person.try(:participant)
  end

  ##
  # Return the Person record with the associated person_id attribute
  #
  # @return Person
  def person
    Person.where(:person_id => @person_id).first
  end

  ##
  # True if current_state == scheduled
  def scheduled?
    @current_state == PatientStudyCalendar::ACTIVITY_SCHEDULED
  end

  ##
  # Return a copy of this ScheduledActivity
  #
  # @return ScheduledActivity
  def copy
    result = ScheduledActivity.new
    self.instance_variable_names.each do |v|
      key = v.sub('@','')
      result.send("#{key}=", self.send("#{key}"))
    end
    result
  end

end