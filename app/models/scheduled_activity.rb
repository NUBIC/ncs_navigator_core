class ScheduledActivity

  attr_accessor :study_segment, :activity_id, :current_state, :ideal_date, :date, :activity_name, :activity_type, :labels, :person_id
  attr_accessor :event, :instrument, :order, :participant_type, :collection, :mode

  def initialize(attrs={})
    attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    parse_labels if @labels
  end

  ##
  # Extract data from the labels
  # and set as attributes on self
  def parse_labels
    @labels.split.each do |lbl|
      k, v = lbl.split(':')
      self.send("#{k}=", v)
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
  # True if activity_type includes 'Consent'
  # @return [Boolean]
  def consent_activity?
    @activity_type.to_s.include? "Consent"
  end

end