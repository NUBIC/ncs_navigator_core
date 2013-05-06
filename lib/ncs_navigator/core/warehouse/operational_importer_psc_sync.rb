# -*- coding: utf-8 -*-

require 'forwardable'

module NcsNavigator::Core::Warehouse
  class OperationalImporterPscSync
    extend Forwardable

    ##
    # The default Redis key generator.
    #
    # Mostly used for namespacing.
    KEYGEN = lambda do |*c|
      [OperationalImporter.name, 'psc_sync', c].flatten.join(':')
    end

    attr_reader :psc, :wh_config, :sync_key
    def_delegators :wh_config, :shell, :log

    def initialize(psc, wh_config, sync_key = KEYGEN)
      @psc = psc
      @wh_config = wh_config
      @sync_key = sync_key
    end

    def import(responsible_user)
      old_whodunnit = PaperTrail.whodunnit

      begin
        PaperTrail.whodunnit = responsible_user
        init_participants_cache

        backup_participants

        i = 1
        p_count = redis.scard(sync_key['participants'])
        while p_id = redis.spop(sync_key['participants'])
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
          close_pending_activities_for_closed_events(psc_participant)
          create_placeholders_for_implied_events(psc_participant)
          i += 1
        end
        shell.clear_line_and_say(
          "PSC sync complete. #{i - 1}/#{p_count} participant#{'s' if p_count != 1} processed.\n")

        report_about_indefinitely_deferred_events
      ensure
        PaperTrail.whodunnit = old_whodunnit
      end
    end

    def report_about_indefinitely_deferred_events
      unschedulable_sets = redis.keys(sync_key['p', '*', 'events_unschedulable']).
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
            event_details_key = sync_key['event', event_id]
            event_details = redis.hgetall(event_details_key)
            log.error("  - Event #{event_id} #{event_details.inspect}")
          end
        end
      end
    end
    private :report_about_indefinitely_deferred_events

    def reset(responsible_user)
      p_backup_key = sync_key['participants_backup']
      if redis.exists p_backup_key
        redis.sunionstore(sync_key['participants'], p_backup_key)
      end

      %w(
        events_deferred events_unschedulable events_closed events_order
        postnatal
      ).each do |reset_key|
        candidates = redis.keys(sync_key['p', '*', reset_key])
        redis.del(*candidates) unless candidates.empty?
      end

      core_placeholder_event_ids =
        Version.select(:item_id).where(:whodunnit => responsible_user, :item_type => 'Event', :event => 'create').collect(&:item_id)
      Event.where('id IN (?)', core_placeholder_event_ids).destroy_all

      core_updated_event_ids_and_changes = Version.where(:whodunnit => responsible_user, :item_type => 'Event', :event => 'update').order(:created_at).collect { |v| [v.item_id, v.changeset] }
      core_updated_events_by_id = Event.where(:id => core_updated_event_ids_and_changes.collect { |e_and_c| e_and_c.first }).each_with_object({}) { |evt, index| index[evt.id] = evt }
      core_updated_event_ids_and_changes.each { |event_id, changes| reverse_changes(core_updated_events_by_id[event_id], changes) }
    end

    def reverse_changes(event, changes)
      changes.each { |att, att_changes| event.update_attributes(att.to_sym => att_changes.first) }
    end
    private :reverse_changes

    ###### SCHEDULING SEGMENTS FOR EVENTS

    def schedule_events(psc_participant)
      p_id = psc_participant.participant.p_id
      log.info("Syncing events for #{p_id} to PSC")

      say_subtask_message("sorting events")
      event_order_key = sync_key['p', p_id, 'events_order']
      redis.sort(
        sync_key['p', p_id, 'events'],
        :by => sync_key['event', '*'] + '->sort_key',
        :order => 'alpha',
        :store => event_order_key)
      log.debug "Determined order: #{redis.lrange(event_order_key, 0, -1).inspect}"

      event_deferred_key = sync_key['p', p_id, 'events_deferred']
      while event_id = redis.lpop(event_order_key)
        schedule_event_if_appropriate(
          psc_participant, event_id, :defer_key => event_deferred_key)
      end

      while event_id = redis.spop(event_deferred_key)
        schedule_event_if_appropriate(
          psc_participant, event_id, :defer_key => sync_key['p', p_id, 'events_unschedulable'])
      end
    end

    def schedule_event_if_appropriate(psc_participant, event_id, opts={})
      p_id = psc_participant.participant.p_id

      event_details_key = sync_key['event', event_id]
      event_details = redis.hgetall(event_details_key)
      if event_details.empty?
        fail "Could not find event details using #{event_details_key}"
      end

      unless event_details['end_date'].blank?
        redis.sadd(sync_key['p', p_id, 'events_closed'], event_id)
      end

      start_date = event_details['start_date']
      label = event_details['event_type_label']
      say_subtask_message("looking for #{label} on #{start_date}")

      if psc_event = find_psc_event(psc_participant, start_date, label)
        if existing_event = Event.find_by_event_id(event_id)
          existing_event.update_attributes(:psc_ideal_date => psc_event[:start_date])
        end
      else
        schedule_new_segment_for_event(psc_participant, event_id, event_details, opts)
      end

      if event_details['event_type_label'] == 'birth'
        redis.set(sync_key['p', p_id, 'postnatal'], 'true')
      end

      # TODO: if still needed, update the event record to associate
      # the seg ID
    end
    private :schedule_event_if_appropriate

    def schedule_new_segment_for_event(psc_participant, event_id, event_details, opts)
      p_id = psc_participant.participant.p_id
      start_date = event_details['start_date']
      label = event_details['event_type_label']
      arm = event_details['recruitment_arm']

      if label == 'informed_consent'
        say_subtask_message("skipping informed consent event")
        log.debug("Skipping informed consent for #{p_id} on #{start_date} (#{event_id})")
        return
      end

      say_subtask_message("looking for #{label} in template for #{arm}")
      possible_segments = select_segments(label)
      selected_segment = nil
      if possible_segments.empty?
        fail "No segment found for event type label #{label.inspect}"
      end

      arm_eligible_segments = possible_segments.select { |seg| eligible_segment_for_arm?(seg, arm) }
      if arm_eligible_segments.empty?
        say_subtask_message("skipping because there are no #{arm}-appropriate segments")
        log.debug("Deferring #{event_id} indefinitely to #{opts[:defer_key]} because there is not #{arm}-appropriate segment. Inappropriate segment(s):")
        possible_segments.each do |seg|
          log.debug("- #{seg.parent['name']}: #{seg['name']}")
        end
        redis.sadd(opts[:defer_key], event_id)
        return
      end

      possible_segments = arm_eligible_segments

      if possible_segments.size == 1
        selected_segment = possible_segments.first
      elsif segment_selectable_by_pre_post_natal?(possible_segments)
        pre_or_post = redis.get(sync_key['p', p_id, 'postnatal']) ? 'post' : 'pre'
        selected_segment = possible_segments.inject({}) { |h, seg|
          h[seg['name'] == 'Postnatal' ? 'post' : 'pre'] = seg; h
        }[pre_or_post]
      elsif segment_selectable_by_birth_cohort?(possible_segments)
        birth_cohort = (event_details['pbs_birth_cohort'] == 'true')
        selected_segment = possible_segments.inject({}) { |h, seg|
          h[seg['name'] == 'Birth Cohort' ? true : false] = seg; h
        }[birth_cohort]
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

    def eligible_segment_for_arm?(segment_elt, recruit_arm)
      (segment_elt.parent['name'] == 'LO-Intensity') ^ (recruit_arm == 'hi')
    end
    private :eligible_segment_for_arm?

    def segment_selectable_by_pre_post_natal?(possible_segments)
      segment_names = possible_segments.collect { |seg| seg['name'] }
      # "there are two segments and one of them is Postnatal"
      possible_segments.size == 2 && segment_names.include?('Postnatal') && segment_names.uniq.size == 2
    end
    private :segment_selectable_by_pre_post_natal?

    def segment_selectable_by_birth_cohort?(possible_segments)
      segment_names = possible_segments.collect { |seg| seg['name'] }
      # "there are two segments and one of them is Birth Cohort"
      possible_segments.size == 2 && segment_names.include?('Birth Cohort') && segment_names.uniq.size == 2
    end
    private :segment_selectable_by_birth_cohort?

    ###### CONTACT LINK SA HISTORY UPDATES

    def update_sa_histories(psc_participant)
      p_id = psc_participant.participant.p_id

      # sort is for stable testing order
      say_subtask_message('finding link contact sets')
      lc_set_keys =
        redis.keys(sync_key['p', p_id, 'link_contacts', '*']).sort

      update_sa_histories_from_link_contacts(psc_participant, lc_set_keys,
        lambda { |psc_event, lc_details|
          psc_event[:scheduled_activities] -
            redis.smembers(sync_key['p', p_id, 'link_contact_updated_scheduled_activities'])
        })
    end

    def update_sa_histories_from_link_contacts(
        psc_participant, link_contact_set_keys,
        scheduled_activity_selector, link_contact_set_post_processor=nil
    )
      while lc_set_key = link_contact_set_keys.shift
        say_subtask_message("beginning another link contact set")
        lcs = redis.sort(
          lc_set_key,
          :by => sync_key['link_contact', '*'] + '->sort_key',
          :order => 'alpha')

        # each LC is guaranteed to be for the same event so we can use
        # an exemplar LC to load common pieces
        ex_lc_details = redis.hgetall(sync_key['link_contact', lcs.first])
        ex_event_details = redis.hgetall(sync_key['event', ex_lc_details['event_id']])
        psc_event = find_psc_event(
          psc_participant, ex_event_details['start_date'], ex_event_details['event_type_label'])
        unless psc_event
          log.error "No PSC event found for event #{ex_event_details.inspect}. This should not be possible."
          next
        end

        open_activity_ids = psc_participant.scheduled_activities(:sa_list).select{ |_, activity| activity.open? }.keys

        activity_ids = psc_event.delete(:scheduled_activities)
        psc_event[:scheduled_activities] = activity_ids & open_activity_ids

        sas = scheduled_activity_selector.call(psc_event, ex_lc_details)
        if sas.empty?
          log.warn("Found no scheduled activities for LC set\n" <<
            "- event #{ex_event_details.inspect}\n" <<
            "- example LC #{ex_lc_details.inspect}\n" <<
            "- LC IDs #{lcs.inspect}")
        end

        say_subtask_message('Updating %d SA%s for a set with %d LC%s' % [
            sas.size, ('s' if sas.size != 1),
            lcs.size, ('s' if lcs.size != 1),
          ])
        lcs.each do |lc_id|
          lc_details = redis.hgetall(sync_key['link_contact', lc_id])

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
          redis.sadd(sync_key['p', psc_participant.participant.p_id, 'link_contact_updated_scheduled_activities'], sa_id)
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

    def close_pending_activities_for_closed_events(psc_participant)
      p_id = psc_participant.participant.p_id

      say_subtask_message('examining closed events')

      # cache processed SAs
      all_sas = nil

      while closed_event_id = redis.spop(sync_key['p', p_id, 'events_closed'])
        if redis.sismember(sync_key['p', p_id, 'events_unschedulable'], closed_event_id)
          next
        end

        all_sas ||= psc_participant.scheduled_activities(:sa_content)

        event_details = redis.hgetall(sync_key['event', closed_event_id])
        psc_event = find_psc_event(
          psc_participant, event_details['start_date'], event_details['event_type_label'])
        unless psc_event
          log.error "No PSC event found for closed event #{event_details.inspect}. This should not be possible."
          next
        end

        updates = psc_event[:scheduled_activities].select { |sa_id|
          all_sas[sa_id].open?
        }.collect { |sa_id| all_sas[sa_id] }.inject({}) do |u, sa|
          state = activity_state_for_closed_event(event_details, sa)

          u[sa.activity_id] = {
            'date' => event_details['end_date'],
            'state' => state,
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

    def activity_state_for_closed_event(event_details, activity)
      if event_details['completed']
        Psc::ScheduledActivity::OCCURRED
      else
        if activity.current_state == Psc::ScheduledActivity::CONDITIONAL
          Psc::ScheduledActivity::NA
        else
          Psc::ScheduledActivity::CANCELED
        end
      end
    end

    private :activity_state_for_closed_event

    def create_placeholders_for_implied_events(psc_participant)
      p_id = psc_participant.participant.p_id

      say_subtask_message('looking for implied future events')

      imported_events = redis.smembers(sync_key['p', p_id, 'events']).
        collect { |event_id| event = redis.hgetall(sync_key['event', event_id]) }
      latest_imported_event_date = imported_events.collect { |e| e['start_date'] }.max

      # this doesn't seem like the clearest way to do this
      scheduled_events = psc_participant.scheduled_events.reject { |psc_event|
        imported_events.find { |imported_event|
          find_psc_event([psc_event], imported_event['start_date'], imported_event['event_type_label'])
        }
      }.reject { |psc_event| latest_imported_event_date && (psc_event[:start_date] < latest_imported_event_date) }.
        reject { |psc_event| psc_event[:event_type_label] == 'informed_consent' }

      scheduled_events.each do |implied_event|
        event_type_label = implied_event[:event_type_label]
        event_type = NcsCode.find_event_by_lbl(event_type_label)
        if event_type
          say_subtask_message(
            "creating Core #{event_type.display_text} event on #{implied_event[:start_date]} implied by PSC")

          existing_count = psc_participant.participant.events.where(
            :event_type_code => event_type.local_code, :event_start_date => implied_event[:start_date]).count

          if existing_count == 0
            Event.create_placeholder_record(
              psc_participant.participant,
              implied_event[:start_date],
              event_type.local_code,
              nil # skip scheduled segment id because it is no longer used
              )
          end
        else
          log.warn("Cannot find event for MDES version '#{NcsNavigatorCore.mdes.version}' for psc activity label '#{event_type_label}'")
        end
      end
    end

    ###### GENERAL INFRASTRUCTURE

    private

    def redis
      Rails.application.redis
    end

    SUBTASK_MSG_LEN = 70

    def say_subtask_message(message)
      shell_message = if message.size > SUBTASK_MSG_LEN
                        message[0, SUBTASK_MSG_LEN - 1] + '*'
                      else
                        message
                      end

      log.info(message)
      shell.back_up_and_say(SUBTASK_MSG_LEN, "%-#{SUBTASK_MSG_LEN}s" % shell_message)
    end

    attr_reader :participants
    def init_participants_cache
      p_ids = redis.smembers(sync_key['participants'])
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

      event_type_code = NcsCode.find_event_by_lbl(event_type_label).local_code

      scheduled_events = case psc_participant_or_scheduled_events
                         when Array
                           psc_participant_or_scheduled_events
                         else
                           # must be a psc_participant, then
                           psc_participant_or_scheduled_events.scheduled_events
                         end

      start_date_d = Date.parse(start_date)
      acceptable_match_predicate =
        if Event.participant_one_time_only_event_type_codes.include?(event_type_code.to_i)
          lambda { |d| true }
        else
          lambda { |d| ((start_date_d - 14) .. (start_date_d + 14)).include?(d) }
        end
      scheduled_events.
        select { |psc_event| psc_event[:event_type_label] == event_type_label }.
        find { |psc_event| acceptable_match_predicate[Date.parse(psc_event[:start_date])] }
    end
    private :find_psc_event

    def backup_participants
      backup_key = sync_key['participants_backup']
      p_key = sync_key['participants']
      if redis.sdiff(backup_key, p_key).empty?
        redis.sunionstore(backup_key, p_key)
      else
        shell.say_line("Resuming without reset; not backing up participant list.")
      end
    end
    private :backup_participants
  end
end
