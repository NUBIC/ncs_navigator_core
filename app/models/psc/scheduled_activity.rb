require 'digest/sha1'
require 'patient_study_calendar'

module Psc
  ##
  # Attributes for the ScheduledActivity struct.
  #
  # Note: the to_sym call at the end is important.  See
  # http://ruby-doc.org/core-1.9.3/Struct.html#method-c-new for what Struct.new
  # does with a leading String.
  SCHEDULED_ACTIVITY_ATTRS = %w(
    activity_date
    activity_id
    activity_name
    activity_time
    activity_type
    current_state
    ideal_date
    labels
    person_id
    responsible_user
    study_segment
  ).map(&:to_sym)

  ##
  # Represents a scheduled activity from PSC's scheduled activity report or
  # PSC's participant schedules.  (The two services present similar, but not
  # identical, data structures.)
  #
  # This class provides:
  #
  # * constructors for those two situations
  # * helpers for extracting information from activity labels
  # * normalization of data structures (i.e. all labels are presented as lists)
  # * derivation of implied operational data entities
  # * structural equality via Struct
  #
  # While you MAY use ScheduledActivity in the same way that you would use any
  # Struct (i.e. passing all parameters to .new), keep in mind that a
  # ScheduledActivity is defined by many parameters and the order of said
  # parameters is NOT guaranteed to be stable.  You SHOULD use the above
  # constructors.
  #
  #
  # On scheduled activity labels
  # ============================
  #
  # Scheduled activities are linked to Cases entities by way of textual labels.
  # Labels on activities look like this:
  #
  #     event:birth
  #     instrument:2.0:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name
  #     references:2.0:ins_que_birth_int_ehpbhi_p2_v2.0
  #     order:01_01
  #     participant_type:child
  #
  # The meanings of these labels are explained below.
  #
  # event
  # -----
  #
  # The event label links an activity to an {Event}.  The label text is an
  # event type, downcased, with underscores substituted for spaces.  See
  # {Event#matches_activity}.
  #
  # instrument
  # ----------
  #
  # The instrument label links an activity to a {Survey}; an {Instrument} can
  # then be started (via {Instrument.start}) for that Survey, thereby linking
  # the activity to the Instrument.  The label text is a {Survey} title
  # transformed by {Surveyor::Common.to_normalized_string}.
  #
  # references
  # ----------
  #
  # This label's text has a form identical to that of the instrument label, and
  # can be interpreted identically.  However, the label adds a dependency to
  # the activity of the form
  #
  #     This activity is administered with an instrument, which must be
  #     administered with the referenced instrument.
  #
  # Activities that have a references label MUST also have an instrument
  # label.  Activities that violate this are erroneous.
  #
  # Reference labels MUST reference instruments that are (1) referenced in
  # the schedule or report, and (2) are present on activities that do not
  # reference any other instruments.   (Hereafter, such activities will be
  # called "root activities".)
  #
  # Activities that violate any of the above requirements SHOULD be considered
  # erroneous by any subsystem that relies on any of those requirements.
  #
  # order
  # -----
  #
  # The order in which a referrer should be administered relative to its
  # referenced instrument, if any such reference exists.  Instruments belonging
  # to root activities SHOULD be ordered before their dependencies.
  #
  # participant_type
  # ----------------
  #
  # The participant type.  Acceptable values are "self", "mother", and "child".
  #
  # collection
  # ----------
  #
  # If present, this activity involves specimen collection.  Acceptable values
  # are "biological" and "environmental".
  #
  # Biological collections involve obtaining specimens from a biological entity
  # (i.e. person); environmental collections involve obtaining specimens from
  # the environment inhabited by a biological entity.
  #
  #
  # mode
  # ----
  #
  # TODO
  #
  #
  # On derived entities
  # ===================
  #
  # Each activity implies a number of entities in Cases.  They are:
  #
  # * {Contact}
  # * {Event}
  # * {Instrument}
  # * {Person}
  # * {Survey}, main
  # * {Survey}, referenced
  #
  # Invoking {#derive_implied_entities} will write implied entity stubs to
  # contact, event, ..., survey, and referenced_survey.
  #
  # Many activities may imply the same entity; each activity for a given
  # subject, for example, will imply the same person.  You should de-duplicate
  # these implied entities before inserting them into Cases.
  # {Psc::ScheduledActivityReport} is one way to accomplish that.
  class ScheduledActivity < Struct.new(*SCHEDULED_ACTIVITY_ATTRS)
    alias_method :name, :activity_name
    alias_method :id, :activity_id

    # Activity states.
    STATES = [
      CANCELED    = 'canceled',
      CONDITIONAL = 'conditional',
      MISSED      = 'missed',
      NA          = 'NA',
      OCCURRED    = 'occurred',
      SCHEDULED   = 'scheduled'
    ]

    OPEN_STATES = [SCHEDULED, CONDITIONAL]

    attr_reader :contact
    attr_reader :contact_link
    attr_reader :event
    attr_reader :instrument
    attr_reader :person
    attr_reader :survey
    attr_reader :referenced_survey

    ##
    # Constructs an instance of this class from a scheduled activity report row.
    def self.from_report(row)
      new.tap do |a|
        a.activity_date = row['scheduled_date']
        a.activity_id = row['grid_id']
        a.activity_name = row['activity_name']
        a.activity_type = row['activity_type']
        a.current_state = row['activity_status']
        a.ideal_date = row['ideal_date']
        a.labels = row['labels']
        a.person_id = row['subject']['person_id'] if row['subject']
        a.responsible_user = row['responsible_user']
      end
    end

    ##
    # Constucts an instance of this class from a row in a participant schedule.
    def self.from_schedule(row)
      new.tap do |a|
        if row['activity']
          a.activity_name = row['activity']['name']
          a.activity_type = row['activity']['type']
        end

        if (state = row['current_state'])
          a.activity_date = state['date']
          a.activity_time = state['time']
          a.current_state = state['name']
        end

        if (assign = row['assignment'])
          a.person_id = assign['id']

          if assign['subject_coordinator']
            a.responsible_user = assign['subject_coordinator']['username']
          end
        end

        a.activity_id = row['id']
        a.ideal_date = row['ideal_date']
        a.labels = row['labels']
        a.study_segment = row['study_segment']
      end
    end

    def initialize(*args)
      if args.length == 1 && args.first.respond_to?(:each_pair)
        super()

        args.first.each { |k, v| send("#{k}=", v) }
      else
        super
      end

      @label_list ||= []
    end

    def derive_implied_entities(ver = NcsNavigatorCore.mdes_version.number)
      im = ImpliedEntities

      @person = im::Person.new(person_id)
      @contact = im::Contact.new(activity_date, person)

      evl = event_label(ver)
      inl = instrument_label(ver)
      rfl = references_label(ver)
      orl = order_label(ver)

      if evl
        @event = im::Event.new(evl, ideal_date, contact, person)
      end

      if inl
        @survey = im::Survey.new(inl, participant_type_label(ver), orl)
      end

      if rfl
        @referenced_survey = im::SurveyReference.new(rfl)
      end

      if event && survey && !referenced_survey
        @instrument = im::Instrument.new(survey,
                                         referenced_survey,
                                         activity_name,
                                         event,
                                         person,
                                         orl)
      end

      @contact_link = im::ContactLink.new(person, contact, event, instrument)
    end

    def labels=(v)
      super

      @label_list = case v
                    when String then v.split(' ')
                    when NilClass then []
                    else v
                    end

      @label_list.map! { |l| ActivityLabel.from_string(l) }
    end

    ##
    # True if the activity's state is SCHEDULED or CONDITIONAL, false
    # otherwise.
    def open?
      OPEN_STATES.include?(downcased_state)
    end

    ##
    # True if the activity is not open and the activity state is not blank,
    # false otherwise.
    def closed?
      !open? && !current_state.blank?
    end

    ##
    # True if the activity is scheduled, false otherwise.
    def scheduled?
      downcased_state == SCHEDULED
    end

    ##
    # True if the activity is canceled, false otherwise.
    def canceled?
      downcased_state == CANCELED
    end

    ##
    # Label readers.
    %w(collection event instrument order participant_type references).each do |prefix|
      str = <<-END
        def #{prefix}_label(mdes_version = NcsNavigatorCore.mdes_version.number)
          label_with("#{prefix}", mdes_version)
        end
      END

      class_eval str, __FILE__, __LINE__
    end

    ##
    # True if this activity involves specimen collection for a given MDES
    # version, false otherwise.
    def specimen_collection?
      collection_label
    end

    ##
    # @private
    def label_with(prefix, mdes_version)
      @label_list.detect do |l|
        l.has_prefix?(prefix) && l.for_mdes_version?(mdes_version)
      end
    end

    ##
    # @private
    def downcased_state
      current_state.to_s.downcase
    end
  end
end
