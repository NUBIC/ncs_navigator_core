require 'forwardable'

module NcsNavigator::Core::Warehouse
  class OperationalImporterPscSync
    extend Forwardable

    attr_reader :psc, :wh_config
    def_delegators :wh_config, :shell, :log

    def initialize(psc, wh_config)
      @psc = psc
      @wh_config = wh_config
    end

    def import
      init_participants_cache
      while p_id = redis.spop(sync_key('participants'))
        shell.clear_line_and_say("PSC sync of #{p_id}: %#{SUBTASK_MSG_LEN}s" % '')
        p = participants[p_id]
        unless p
          log.error("Participant #{p_id} was registered for PSC sync but not found in core.")
          shell.say("not found in core.")
          next
        end

        psc_participant = psc.psc_participant(participants[p_id])
        schedule_events(psc_participant)
        # update_activities_for_contacts
        # update_activities_for_closed_events

        # TODO: find schedule-implied events that have no Event
        # records in Core and do something with them.

        # TODO: report on indefinitely deferred events, if any.
      end
    end

    SUBTASK_MSG_LEN = 49

    ###### SCHEDULING SEGMENTS FOR EVENTS

    def schedule_events(psc_participant)
      p_id = psc_participant.participant.p_id
      log.info("Syncing events for #{p_id} to PSC")

      say_subtask_message("sorting events")
      event_order_key = sync_key('p', p_id, 'events_order')
      redis.sort(
        sync_key('p', p_id, 'events'),
        :by => sync_key('event', '*') + '->sort_key',
        :order => 'alpha',
        :store => event_order_key)
      log.debug "Determined order: #{redis.lrange(event_order_key, 0, -1).inspect}"

      event_deferred_key = sync_key('p', p_id, 'events_deferred')
      while event_id = redis.lpop(event_order_key)
        schedule_event_if_appropriate(
          psc_participant, event_id, :defer_key => event_deferred_key)
      end

      while event_id = redis.spop(event_deferred_key)
        schedule_event_if_appropriate(
          psc_participant, event_id, :defer_key => sync_key('p', p_id, 'events_unschedulable'))
      end
    end

    def schedule_event_if_appropriate(psc_participant, event_id, opts={})
      p_id = psc_participant.participant.p_id

      event_details_key = sync_key('event', event_id)
      event_details = redis.hgetall(event_details_key)
      if event_details.empty?
        fail "Could not find event details using #{event_details_key}"
      end

      if event_details['end_date']
        redis.sadd(sync_key('p', p_id, 'events_closed'), event_id)
      end

      start_date = event_details['start_date']
      label = event_details['event_type_label']
      say_subtask_message("looking for #{label} on #{start_date}")

      start_date_d = Date.parse(start_date)
      acceptable_match_range = ((start_date_d - 14) .. (start_date_d + 14))
      existing_psc_event = psc_participant.scheduled_events.
        select { |psc_event| psc_event[:event_type_label] == label }.
        find { |psc_event| acceptable_match_range.include?(Date.parse(psc_event[:start_date])) }
      unless existing_psc_event
        schedule_new_segment_for_event(psc_participant, event_id, event_details, opts)
      end

      # TODO: if still needed, update the event record to associate
      # the seg ID
    end
    private :schedule_event_if_appropriate

    def schedule_new_segment_for_event(psc_participant, event_id, event_details, opts)
      p_id = psc_participant.participant.p_id
      start_date = event_details['start_date']
      label = event_details['event_type_label']

      say_subtask_message("looking for #{label} in template")
      possible_segments = select_segments(label)
      selected_segment = nil
      if possible_segments.empty?
        fail "No segment found for event type label #{label.inspect}"
      elsif possible_segments.size == 1
        selected_segment = possible_segments.first
      elsif label == 'birth'
        selected_segment = possible_segments.inject({}) { |h, seg|
          h[seg.parent['name'] == 'LO-Intensity'] = seg; h
        }[psc_participant.participant.low_intensity?]
      else
        say_subtask_message("deferring due to multiple segment options")
        log.debug("Deferring #{event_id} to #{opts[:defer_key]} due to multiple possible segments:")
        possible_segments.each do |seg|
          log.debug("- #{seg.parent['name']}: #{seg['name']}")
        end
        redis.sadd(opts[:defer_key], event_id)
        return
      end

      if selected_segment.nil?
        fail "Could not determine segment to use for #{label.inspect} from " +
          "#{possible_segments.collect { |seg| "#{seg.parent['name']}: #{seg['name']}" }.inspect}"
      end

      if psc_participant.registered?
        say_subtask_message("appending segment #{selected_segment['name'].inspect}")
        log.info "Appending segment #{selected_segment['name'].inspect} " +
          "starting #{start_date} for #{p_id}"
        psc_participant.
          append_study_segment(start_date, selected_segment['id'])
      else
        say_subtask_message("registering; starting with #{selected_segment['name'].inspect}")
        log.info "Registering #{p_id} on #{start_date} " +
          "starting with #{selected_segment['name'].inspect}"
        psc_participant.register!(event_details['start_date'], selected_segment['id'])
      end
    end
    private :schedule_new_segment_for_event

    def select_segments(event_type_label)
      psc.template_snapshot.
        xpath("//psc:study-segment//psc:label[@name='event:#{event_type_label}']", Psc.xml_namespace).
        collect { |label_elt| label_elt.xpath('../../..') }.flatten.uniq
    end
    private :select_segments

    ###### GENERAL INFRASTRUCTURE

    private

    def sync_key(*key_parts)
      [OperationalImporter.name, 'psc_sync', key_parts].flatten.join(':')
    end

    def redis
      Rails.application.redis
    end

    def say_subtask_message(message)
      if message.size > SUBTASK_MSG_LEN
        message = message[0, SUBTASK_MSG_LEN - 1] + '*'
      end
      shell.back_up_and_say(SUBTASK_MSG_LEN, "%-#{SUBTASK_MSG_LEN}s" % message)
    end

    attr_reader :participants
    def init_participants_cache
      p_ids = redis.smembers(sync_key('participants'))
      shell.clear_line_then_say(
        "Loading #{p_ids.size} participant#{'s' unless p_ids.size == 1} for PSC sync...")

      @participants = Participant.
        includes(:participant_person_links => [:person]).
        where(:p_id => p_ids).inject({}) { |idx, p| idx[p.p_id] = p; idx }
      ct = participants.size
      shell.clear_line_then_say(
        "Loaded #{ct} participant#{'s' unless ct == 1} for PSC sync.\n")
    end
  end
end
