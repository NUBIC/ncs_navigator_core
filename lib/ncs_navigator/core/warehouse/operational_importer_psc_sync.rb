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

      backup_participants

      i = 1
      p_count = redis.scard(sync_key('participants'))
      while p_id = redis.spop(sync_key('participants'))
        shell.clear_line_and_say("PSC sync of #{p_id} (#{i}/#{p_count}): %#{SUBTASK_MSG_LEN}s" % '')
        p = participants[p_id]
        unless p
          log.error("Participant #{p_id} was registered for PSC sync but not found in core.")
          say_subtask_message("not found in core.")
          next
        end

        psc_participant = psc.psc_participant(participants[p_id])
        schedule_events(psc_participant)
        update_sa_histories(psc_participant)
        cancel_pending_activities_for_closed_events(psc_participant)
        create_placeholders_for_implied_events(psc_participant)

        i += 1
      end
      shell.clear_line_and_say(
        "PSC sync complete. #{i - 1}/#{p_count} participant#{'s' if p_count != 1} processed.")

      report_about_indefinitely_deferred_events
    end

    def report_about_indefinitely_deferred_events
      unschedulable_sets = redis.keys(sync_key('p', '*', 'events_unschedulable')).
        select { |set_key| redis.scard(set_key) > 0 }
      unless unschedulable_sets.empty?
        shell.say_line(
          "%d participant%s had events that could not be sync'd. See log for details." %
          [unschedulable_sets.size, ('s' if unschedulable_sets.size > 1)])
        log.error((
            "The following %d participant%s had one or more events that were not sync'd " +
            'to PSC because they could never be unambiguously mapped to PSC segments.') %
          [unschedulable_sets.size, ('s' if unschedulable_sets.size > 1)])
        unschedulable_sets.each do |set_key|
          p_id = set_key.scan(/p\:([^:]+)\:events_/).first.first
          log.error("= Participant #{p_id}")
          redis.smembers(set_key).each do |event_id|
            event_details_key = sync_key('event', event_id)
            event_details = redis.hgetall(event_details_key)
            log.error("  - Event #{event_id} #{event_details.inspect}")
          end
        end
      end
    end
    private :report_about_indefinitely_deferred_events

    def reset
      p_backup_key = sync_key('participants_backup')
      if redis.exists p_backup_key
        redis.sunionstore(sync_key('participants'), p_backup_key)
      end

      %w(events_deferred events_unschedulable events_closed events_order).each do |reset_key|
        redis.del redis.keys(sync_key('p', '*', reset_key))
      end
    end

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

      unless event_details['end_date'].blank?
        redis.sadd(sync_key('p', p_id, 'events_closed'), event_id)
      end

      start_date = event_details['start_date']
      label = event_details['event_type_label']
      say_subtask_message("looking for #{label} on #{start_date}")

      unless find_psc_event(psc_participant, start_date, label)
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
      elsif segment_selectable_by_hi_v_lo?(possible_segments)
        selected_segment = possible_segments.inject({}) { |h, seg|
          h[seg.parent['name'] == 'LO-Intensity' ? 'lo' : 'hi'] = seg; h
        }[event_details['recruitment_arm']]
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

    def segment_selectable_by_hi_v_lo?(possible_segments)
      epoch_names = possible_segments.collect { |seg| seg.parent['name'] }
      # "there are two different epochs and one of them is LO-Intensity"
      epoch_names.size == 2 && epoch_names.include?('LO-Intensity') && epoch_names.uniq.size == 2
    end

    ###### CONTACT LINK SA HISTORY UPDATES

    def update_sa_histories(psc_participant)
      update_instrument_sa_histories(psc_participant)
      update_other_event_sa_histories(psc_participant)
    end

    def update_instrument_sa_histories(psc_participant)
      p_id = psc_participant.participant.p_id

      say_subtask_message('finding link contact sets (with instruments)')
      lc_set_keys =
        redis.keys(sync_key('p', p_id, 'link_contacts_with_instrument', '*'))

      all_sas = psc_participant.scheduled_activities(:sa_list)

      update_sa_histories_from_link_contacts(psc_participant, lc_set_keys, 'with instruments',
        lambda { |psc_event, lc_details|
          instrument_filename = InstrumentEventMap.
            instrument_map_value_for_code(lc_details['instrument_type'].to_i, 'filename').downcase
          psc_event[:scheduled_activities].select { |event_sa_id|
            all_sas[event_sa_id]['labels'] =~ /\binstrument:#{instrument_filename}\b/
          }
        },
        lambda { |link_contact_ids, scheduled_activities|
          last_details = redis.hgetall(sync_key('link_contact', link_contact_ids.last))
          if last_details['instrument_status'] == 'complete'
            say_subtask_message("marking SA for a completed instrument occurred")
            batch_update_sa_states(psc_participant, scheduled_activities, {
                'date' => last_details['contact_date'],
                'reason' => "Imported completed instrument #{last_details['instrument_id']}.",
                'state' => 'occurred'
              })
          end
        })

    end
    private :update_instrument_sa_histories

    def update_other_event_sa_histories(psc_participant)
      p_id = psc_participant.participant.p_id

      # sort is for stable testing order
      say_subtask_message('finding link contact sets (with event only)')
      lc_set_keys =
        redis.keys(sync_key('p', p_id, 'link_contacts_without_instrument', '*')).sort

      update_sa_histories_from_link_contacts(psc_participant, lc_set_keys, 'with event only',
        lambda { |psc_event, lc_details|
          psc_event[:scheduled_activities] -
            redis.smembers(sync_key('p', p_id, 'link_contact_updated_scheduled_activities'))
        })
    end
    private :update_other_event_sa_histories

    def update_sa_histories_from_link_contacts(
        psc_participant, link_contact_set_keys, set_type,
        scheduled_activity_selector, link_contact_set_post_processor=nil
    )
      while lc_set_key = link_contact_set_keys.shift
        say_subtask_message("beginning another link contact set (#{set_type})")
        lcs = redis.sort(
          lc_set_key,
          :by => sync_key('link_contact', '*') + '->sort_key',
          :order => 'alpha')

        # each LC is guaranteed to be for the same event so we can use
        # an exemplar LC to load common pieces
        ex_lc_details = redis.hgetall(sync_key('link_contact', lcs.first))
        ex_event_details = redis.hgetall(sync_key('event', ex_lc_details['event_id']))
        psc_event = find_psc_event(
          psc_participant, ex_event_details['start_date'], ex_event_details['event_type_label'])
        unless psc_event
          log.error "No PSC event found for event #{ex_event_details.inspect}. This should not be possible."
          next
        end

        sas = scheduled_activity_selector.call(psc_event, ex_lc_details)
        if sas.empty?
          log.warn("Found no scheduled activities for LC set #{set_type}\n" <<
            "- event #{ex_event_details.inspect}\n" <<
            "- example LC #{ex_lc_details.inspect}\n" <<
            "- LC IDs #{lcs.inspect}")
        end

        say_subtask_message('Updating %d SA%s for a set with %d LC%s (%s)' % [
            sas.size, ('s' if sas.size != 1),
            lcs.size, ('s' if lcs.size != 1),
            set_type
          ])
        lcs.each do |lc_id|
          lc_details = redis.hgetall(sync_key('link_contact', lc_id))

          batch_update_sa_states(psc_participant, sas, {
              'date' => lc_details['contact_date'],
              'reason' => "Imported #{lc_details['status']} contact link #{lc_id}.",
              'state' => 'scheduled'
            })
        end

        if link_contact_set_post_processor
          link_contact_set_post_processor.call(lcs, sas)
        end

        sas.each do |sa_id|
          redis.sadd(sync_key('p', psc_participant.participant.p_id, 'link_contact_updated_scheduled_activities'), sa_id)
        end
      end
    end
    private :update_sa_histories_from_link_contacts

    ##
    # Updates a list of SAs to a new state (the same state for all of them)
    def batch_update_sa_states(psc_participant, scheduled_activities, new_state)
      return if scheduled_activities.empty?
      psc_participant.update_scheduled_activity_states(
        scheduled_activities.inject({}) { |update, sa_id| update[sa_id] = new_state; update })
    end
    private :batch_update_sa_states

    ###### CANCEL REMAINING ACTIVITIES FOR CLOSED EVENTS

    def cancel_pending_activities_for_closed_events(psc_participant)
      p_id = psc_participant.participant.p_id

      say_subtask_message('examining closed events')

      # cache processed SAs
      all_sas = nil

      while closed_event_id = redis.spop(sync_key('p', p_id, 'events_closed'))
        if redis.sismember(sync_key('p', p_id, 'events_unschedulable'), closed_event_id)
          next
        end

        all_sas ||= psc_participant.scheduled_activities(:sa_content)

        event_details = redis.hgetall(sync_key('event', closed_event_id))
        psc_event = find_psc_event(
          psc_participant, event_details['start_date'], event_details['event_type_label'])
        unless psc_event
          log.error "No PSC event found for closed event #{event_details.inspect}. This should not be possible."
          next
        end

        updates = psc_event[:scheduled_activities].select { |sa_id|
          %w(scheduled conditional).include?(all_sas[sa_id]['current_state']['name'])
        }.collect { |sa_id| all_sas[sa_id] }.inject({}) do |u, sa|
          u[sa['id']] = {
            'date' => event_details['end_date'],
            'state' => sa['current_state']['name'] == 'conditional' ? 'NA' : 'canceled',
            'reason' => "Imported closed event #{closed_event_id}."
          }
          u
        end

        unless updates.empty?
          say_subtask_message("canceling pending SAs for closed event #{closed_event_id}")
          psc_participant.update_scheduled_activity_states(updates)
        end
      end
    end

    def create_placeholders_for_implied_events(psc_participant)
      p_id = psc_participant.participant.p_id

      say_subtask_message('looking for implied future events')

      imported_events = redis.smembers(sync_key('p', p_id, 'events')).
        collect { |event_id| event = redis.hgetall(sync_key('event', event_id)) }
      latest_imported_event_date = imported_events.collect { |e| e['start_date'] }.max

      # this doesn't seem like the clearest way to do this
      scheduled_events = psc_participant.scheduled_events.reject { |psc_event|
        imported_events.find { |imported_event|
          find_psc_event([psc_event], imported_event['start_date'], imported_event['event_type_label'])
        }
      }.reject { |psc_event| psc_event[:start_date] < latest_imported_event_date }

      scheduled_events.each do |implied_event|
        event_type = NcsCode.find_event_by_lbl(implied_event[:event_type_label])
        say_subtask_message(
          "creating Core #{event_type.display_text} event on #{implied_event[:start_date]} implied by PSC")

        Event.create_placeholder_record(
          psc_participant.participant,
          implied_event[:start_date],
          event_type.local_code,
          nil # skip scheduled segment id because it is no longer used
          )
      end
    end

    ###### GENERAL INFRASTRUCTURE

    private

    def sync_key(*key_parts)
      [OperationalImporter.name, 'psc_sync', key_parts].flatten.join(':')
    end

    def redis
      Rails.application.redis
    end

    SUBTASK_MSG_LEN = 70

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

    def find_psc_event(psc_participant_or_scheduled_events, start_date, event_type_label)
      fail 'Cannot find a PSC event without a start date' unless start_date

      scheduled_events = case psc_participant_or_scheduled_events
                         when Array
                           psc_participant_or_scheduled_events
                         else
                           # must be a psc_participant, then
                           psc_participant_or_scheduled_events.scheduled_events
                         end

      start_date_d = Date.parse(start_date)
      acceptable_match_range = ((start_date_d - 14) .. (start_date_d + 14))
      scheduled_events.
        select { |psc_event| psc_event[:event_type_label] == event_type_label }.
        find { |psc_event| acceptable_match_range.include?(Date.parse(psc_event[:start_date])) }
    end
    private :find_psc_event

    def backup_participants
      backup_key = sync_key('participants_backup')
      p_key = sync_key('participants')
      if redis.sdiff(backup_key, p_key).empty?
        redis.sunionstore(backup_key, p_key)
      else
        shell.say_line("Resuming without reset; not backing up participant list.")
      end
    end
    private :backup_participants
  end
end
