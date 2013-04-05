class ScheduledActivity
  include Comparable

  attr_accessor :study_segment, :activity_id, :activity_time, :ideal_date, :date, :activity_name, :activity_type
  attr_accessor :event, :person_id, :current_state, :order, :participant_type, :collection, :mode
  attr_accessor :labels, :references_collection, :references, :instruments, :instrument, :forms, :form

  def initialize(attrs={})
    attrs.each { |k, v| send("#{k}=", v) if respond_to?("#{k}=") }
    @instruments ||= []
    @references_collection ||= []
    @forms ||= []
    parse_labels if @labels
  end

  ##
  # Return the 'form' (internal_survey) or
  # 'instrument' (survey) from the parsed labels
  # or nil if neither exist
  def survey_identifier
    @form || @instrument
  end

  ##
  # Extract data from the labels
  # and set as attributes on self
  def parse_labels
    @labels.split.each do |lbl|
      vals = lbl.split(':')
      v = vals.first
      case v
      when "form"
        handle_form_label vals
      when "instrument"
        handle_instrument_label vals
      when "references"
        handle_references_label vals
      else
        if valid_setters.include?(v.to_sym)
          self.send("#{v}=", vals.last)
        end
      end
    end
  end
  private :parse_labels

  ##
  # Some labels do not match the instance_methods for this class.
  # Determine the attributes that can be set.
  def valid_setters
    methods = ScheduledActivity.instance_methods
    @valid_setters ||= methods.select do |m|
      methods.include?(:"#{m}=")
    end
  end
  private :valid_setters

  ##
  # Takes the form label values and adds
  # the form label value to the forms collection.
  # If the form label matches the mdes version, also
  # set the form value.
  def handle_form_label(vals)
    @forms << vals.last
    @form = vals.last if matches_mdes_version(vals)
  end
  private :handle_form_label

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
  # True if activity_name ends with SAQ
  # @return [Boolean]
  def saq_activity?
    @activity_name.to_s.ends_with?("SAQ")
  end

  ##
  # True if activity_type includes 'Consent'
  # @return [Boolean]
  def consent_activity?
    @activity_type.to_s.include? "Consent"
  end

  ##
  # Returns true if this activity is a reconsent
  # @return [Boolean]
  def reconsent?
    @activity_name == "Reconsent"
  end

  ##
  # Returns true if this activity is a withdrawal
  # @return [Boolean]
  def withdrawal?
    @activity_name == "Withdrawal"
  end

  ##
  # All other consent activities that are not a child consent
  # reconsent or withdrawal
  # @return [Boolean]
  def informed_consent?
    consent_activity? && !reconsent? && !withdrawal? && !child_consent?
  end

  ##
  # True if activity_name == "Child Consent"
  # @return [Boolean]
  def child_consent?
    @activity_name.include? "Child Consent"
  end

  ##
  # True if activity_name == "Child Consent Birth to Six Months"
  # @return [Boolean]
  def child_consent_birth_to_6_months?
    @activity_name == "Child Consent Birth to Six Months"
  end

  ##
  # True if activity_name == "Child Consent Six Months to Age of Majority"
  # @return [Boolean]
  def child_consent_6_months_to_age_of_majority?
    @activity_name == "Child Consent Six Months to Age of Majority"
  end

  ##
  # Returns the survey title that this scheduled activity is a part of.
  # @return String
  def survey_root
    @references.blank? ? survey_identifier : @references
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
  # @return[Boolean]
  def scheduled?
    @current_state == Psc::ScheduledActivity::SCHEDULED
  end

  ##
  # True if current_state == conditional
  # @return[Boolean]
  def conditional?
    @current_state == Psc::ScheduledActivity::CONDITIONAL
  end

  ##
  # True if current_state == NA
  # @return[Boolean]
  def not_applicable?
    @current_state == Psc::ScheduledActivity::NA
  end

  ##
  # True if current_state == canceled
  # @return[Boolean]
  def canceled?
    @current_state == Psc::ScheduledActivity::CANCELED
  end

  ##
  # True if current_state == occurred
  # @return[Boolean]
  def occurred?
    @current_state == Psc::ScheduledActivity::OCCURRED
  end

  ##
  # True if current_state == missed
  # @return[Boolean]
  def missed?
    @current_state == Psc::ScheduledActivity::MISSED
  end

  ##
  # True if scheduled or conditional
  # @return[Boolean]
  def open?
    scheduled? or conditional?
  end

  ##
  # True unless scheduled or conditional
  # @return[Boolean]
  def closed?
    !open?
  end

  ##
  # Return a copy of this ScheduledActivity
  #
  # @return ScheduledActivity
  def copy
    result = ScheduledActivity.new
    self.instance_variable_names.each do |v|
      key = v.sub('@','')
      next if should_skip_copy(key)
      result.send("#{key}=", self.send("#{key}"))
    end
    result
  end

  ##
  # Skip copying these instance_variable_names
  def should_skip_copy(key)
    key == "valid_setters"
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
