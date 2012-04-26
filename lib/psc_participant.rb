# -*- coding: utf-8 -*-

require 'forwardable'

##
# Interface to a particular participant's PSC schedule. Does not
# assume that the PSC schedule already exists.
#
# Provides for caching of scheduled activities with invalidation at
# two levels: `:sa_list` (has the list of SAs changed?) and
# `:sa_content` (have any SAs' states changed, including date, reason,
# etc.). Since things like ideal date and SA labels are fixed at
# segment initialization, this allows for quicker repeat access to
# some schedule attributes. (Caching and invalidation only works if
# all changes to the participant's schedule are made through the same
# instance of this class.)
class PscParticipant
  extend Forwardable

  attr_reader :psc, :participant, :assignment_identifier, :subject_person_id

  ##
  # @private exposed for testing
  attr_reader :valid

  def_delegators :psc, :connection

  ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS = [:sa_list, :sa_content]

  ##
  # @param [PatientStudyCalendar] psc
  # @param [Participant] participant
  def initialize(psc, participant)
    @psc = psc
    @participant = participant
    @assignment_identifier = psc.psc_assignment_id(participant)
    @subject_person_id = participant.person.person_id
    @valid = ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS.inject({}) { |v, l| v[l] = false; v }
  end

  ##
  # @return [Boolean] is the subject registered in PSC yet?
  def registered?
    return @registered unless @registered.nil?

    result = connection.get(
      resource_path('studies', psc.study_identifier, 'schedules', assignment_identifier))
    case
    when result.success?
      @registered = true
    when result.status == 404
      @registered = false
    else
      raise PatientStudyCalendar::ResponseError.new(result.status, result.body)
    end
  end

  ##
  # Registers the subject in PSC if not already registered.
  #
  # @param [String] start_date the desired start date, formatted as
  #   YYYY-MM-DD.
  # @param [String] segment_id
  def register!(start_date, segment_id)
    return if registered?

    registration_message = Psc.xml('registration',
      'date' => start_date,
      'desired-assignment-id' => assignment_identifier,
      'subject-coordinator-name' => psc.user.username,
      'first-study-segment-id' => segment_id
    ) do |reg|
      reg.subject(subject_attributes(:xml))
    end

    response = connection.post(resource_path(
        'studies', psc.study_identifier, 'sites', psc.site_identifier, 'subject-assignments'
      ), registration_message)

    if response.success?
      @registered = true
      ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS.each { |k| @valid[k] = false }
    else
      raise PatientStudyCalendar::ResponseError.new(response.status, response.body)
    end
  end

  def subject_attributes(xml_or_json=:json)
    attrs = { 'gender' => 'not reported', 'person_id' => subject_person_id }
    attrs = %w(first_name last_name).inject(attrs) do |a, direct_attr|
      if p = participant.person.send(direct_attr)
        a[direct_attr] = p
      end
      a
    end

    if xml_or_json == :xml
      attrs.inject({}) do |a, (k, v)|
        a[k.gsub('_', '-')] = v; a
      end
    else
      attrs
    end
  end
  private :subject_attributes

  ##
  # Appends another segment to the subject's schedule.
  #
  # @param [String] start_date the desired start date, formatted as
  #   YYYY-MM-DD.
  # @param [String] segment_id
  def append_study_segment(start_date, segment_id)
    return unless registered?

    next_study_segment_message = Psc.xml('next-scheduled-study-segment',
      'start-date' => start_date,
      'study-segment-id' => segment_id,
      'mode' => 'per-protocol'
    )

    response = connection.post(
      resource_path('studies', psc.study_identifier, 'schedules', assignment_identifier),
      next_study_segment_message)

    if response.success?
      ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS.each { |k| @valid[k] = false }
    else
      raise PatientStudyCalendar::ResponseError.new(response.status, response.body)
    end
  end

  ##
  # @param [:sa_content, :sa_list] validity the acceptable level of
  #   staleness. The default (`:sa_content`) means that any changes to
  #   the schedule will result in a reload. `:sa_list` means that only
  #   changes that add new SAs (i.e., scheduling a new segment) will
  #   require a reload.
  #
  # @return [Hash] the decoded full representation of the
  #   participant's schedule, as from PSC. Cached.
  def schedule(validity=:sa_content)
    return @schedule if @valid[validity]

    response = connection.get(resource_path('subjects', subject_person_id, 'schedules.json'))

    if response.success?
      ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS.each { |k| @valid[k] = true }
      @schedule = response.body
    elsif response.status == 404
      ALL_SCHEDULED_ACTIVITY_CACHE_LEVELS.each { |k| @valid[k] = true }
      @schedule = {}
    else
      raise PatientStudyCalendar::ResponseError.new(response.status, response.body)
    end
  end

  ##
  # @private exposed for testing
  def schedule=(s)
    @schedule = s
  end

  ##
  # Transforms PSC's date-oriented schedule representation into an
  # hash of scheduled activities indexed by ID.
  #
  # @return [Hash<String, Hash<String, Object>]
  def scheduled_activities(validity=:sa_content)
    # TODO: how to memoize with proper cache invalidation?
    days = schedule(validity)['days']
    return {} unless days
    days.inject({}) do |index, (day, day_value)|
      day_value['activities'].each do |sa|
        index[sa['id']] = sa
      end
      index
    end
  end

  ##
  # Analyzes the subject's schedule and lists the events implied by
  # it. Each event hash has the following structure:
  #
  #     {
  #       :event_type_label => "pregnancy_visit_1",
  #       :start_date => '2011-01-01',
  #       # the IDs for the SAs
  #       :scheduled_activities => ['sa_id_1', 'sa_id_7', ...]
  #     }
  #
  # @return [Array<Hash<Symbol,Object>>]
  def scheduled_events
    # build a map with key [event_type_label, ideal_date] and value
    # (array of SA IDs)
    event_date_index = scheduled_activities(:sa_list).inject({}) do |index, (sa_id, sa)|
      next index unless sa['labels']
      event = sa['labels'].scan(/\bevent:(\S+)\b/).first.first
      next index unless event
      key = [event, sa['ideal_date']]

      (index[key] ||= []) << sa['id']
      index
    end

    event_date_index.collect do |(event, date), sa_list|
      {
        :event_type_label => event,
        :start_date => date,
        :scheduled_activities => sa_list
      }
    end
  end

  ##
  # Updates one or more scheduled activities with new state data.
  #
  # @param [Hash<String, Hash<String, String>>] new_states the new
  #   state data. The outer key is the SA ID. Each SA ID points to a
  #   hash containing the new state information. The inner hashes should
  #   match those you can submit to PSC's batch SA update resource.
  def update_scheduled_activity_states(new_states)
    response = connection.post(
      resource_path('subjects', subject_person_id, 'schedules', 'activities'), new_states)
    if response.success?
      valid[:sa_content] = false
      if response.status == 207
        problems = response.body.collect { |sa_id, status|
          unless status['Status'] / 100 == 2
            "#{sa_id}, status #{status['Status']}: #{status['Message']} (submitted: #{new_states[sa_id].inspect})"
          end
        }.compact
        unless problems.empty?
          raise PatientStudyCalendar::ResponseError.new(response.status, response.body,
            "Updating SA(s) failed:\n - #{problems.join("\n - ")}")
        end
      end
    elsif !response.success?
      raise PatientStudyCalendar::ResponseError.new(response.status, response.body)
    end
  end

  ##
  # Receives a set of path components, encodes them, and returns the
  # result joined with '/'.
  def resource_path(*components)
    components.collect { |c| URI.escape c }.join('/')
  end
  private :resource_path
end