class ScheduledActivity
  include Comparable

  attr_accessor :study_segment, :activity_id, :current_state, :ideal_date, :date, :activity_name, :activity_type, :labels, :person_id, :time
  attr_accessor :event, :references_collection, :references, :instruments, :instrument, :order, :participant_type, :collection, :mode

  def initialize(attrs={})
    attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    @instruments ||= []
    @references_collection ||= []
    parse_labels if @labels
  end

  ##
  # Extract data from the labels
  # and set as attributes on self
  def parse_labels
    @labels.split.each do |lbl|
      vals = lbl.split(':')
      case vals.first
      when "instrument"
        handle_instrument_label vals
      when "references"
        handle_references_label vals
      else
        self.send("#{vals.first}=", vals.last)
      end
    end
  end
  private :parse_labels

  ##
  # Takes the instrument label values and adds
  # the instrument label value to the instruments collection.
  # If the instrument label matches the mdes version, also
  # set the instrument value.
  def handle_instrument_label(vals)
    @instruments << vals.last
    @instrument = vals.last if matches_mdes_version(vals)
  end
  private :handle_instrument_label

  ##
  # Takes the references label values and adds
  # the references label value to the references collection.
  # If the references label matches the mdes version, also
  # set the references value.
  def handle_references_label(vals)
    @references_collection << vals.last
    @references = vals.last if matches_mdes_version(vals)
  end
  private :handle_references_label


  def matches_mdes_version(vals)
    !vals.select { |v| v == NcsNavigatorCore.mdes.version }.blank?
  end
  private :matches_mdes_version

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
      break unless result
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
  # Returns the survey title that this scheduled activity is a part of.
  # @return String
  def survey_root
    @references.blank? ? @instrument : @references
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
    @current_state == Psc::ScheduledActivity::SCHEDULED
  end

  ##
  # True if current_state == canceled
  def canceled?
    @current_state == Psc::ScheduledActivity::CANCELED
  end

  ##
  # True if current_state == occurred
  def occurred?
    @current_state == Psc::ScheduledActivity::OCCURRED
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

  ##
  # Ensure that those items without an explicit order
  # set in the label are placed at the end
  def order
    @order || "99_99"
  end

  ##
  # Alias for the instrument attribute
  def survey_title
    instrument
  end

  def has_non_matching_mdes_version_instrument?
    labels.include?(Instrument::INSTRUMENT_LABEL_MARKER) && instrument.blank?
  end

end
