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
    activity_type
    current_state
    ideal_date
    labels
    person_id
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
  #     instrument:ins_que_birth_int_ehpbhi_p2_v2.0_baby_name
  #     references:ins_que_birth_int_ehpbhi_p2_v2.0
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
  # TODO
  #
  # mode
  # ----
  #
  # TODO
  class ScheduledActivity < Struct.new(*SCHEDULED_ACTIVITY_ATTRS)
    alias_method :name, :activity_name
    alias_method :id, :activity_id

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

        if row['current_state']
          a.activity_date = row['current_state']['date']
          a.current_state = row['current_state']['name']
        end

        if row['assignment']
          a.person_id = row['assignment']['id']
        end

        a.activity_id = row['id']
        a.ideal_date = row['ideal_date']
        a.labels = row['labels']
        a.study_segment = row['study_segment']
      end
    end

    def initialize(*args)
      super

      @processed_labels ||= []
    end

    def labels=(v)
      super

      @processed_labels = case v
                          when String then v.split(' ')
                          else v
                          end
    end

    ##
    # True if the activity is scheduled, false otherwise.
    def scheduled?
      current_state.to_s.downcase == PatientStudyCalendar::ACTIVITY_SCHEDULED
    end

    ##
    # True if the activity is canceled, false otherwise.
    def canceled?
      current_state.to_s.downcase == PatientStudyCalendar::ACTIVITY_CANCELED
    end

    ##
    # Label readers.
    %w(collection event instrument order participant_type references).each do |prefix|
      str = <<-END
        def #{prefix}_label
          label_with "#{prefix}:"
        end
      END

      class_eval str, __FILE__, __LINE__
    end

    ##
    # @private
    def label_with(prefix)
      label = @processed_labels.detect { |l| l.start_with?(prefix) }

      label.match(/^[^:]+:(.+)$/)[1] if label
    end
  end
end
