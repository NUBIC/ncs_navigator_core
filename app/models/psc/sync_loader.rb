module Psc
  class SyncLoader
    ##
    # Redis connection.
    #
    # Defaults to Rails.application.redis.
    attr_accessor :redis

    ##
    # A procedure to wrap a Redis key with job-specific information.
    #
    # This is used to isolate one sync job from other jobs and identify
    # all keys associated with a job.
    attr_reader :sync_key

    def initialize(sync_key)
      @sync_key = sync_key

      self.redis = Rails.application.redis
    end

    def cache_participant(participant)
      redis.sadd(sync_key['participants'], participant.public_id)
    end

    def cached_participant_ids
      redis.smembers(sync_key['participants'])
    end

    def cached_event_ids
      prefix = sync_key['event', '']

      redis.keys(sync_key['event', '*']).map { |k| k.sub(prefix, '') }
    end

    def cached_contact_link_ids
      prefix = sync_key['link_contact', '']

      redis.keys(sync_key['link_contact', '*']).map { |k| k.sub(prefix, '') }
    end

    def cache_event(event, participant)
      return unless should_cache_event?(event)

      ekey = sync_key['event', event.public_id]
      lkey = sync_key['p', participant.public_id, 'events']

      start_date = event.event_start_date || event.event_end_date
      puts "start_date: #{start_date.inspect}"

      unless start_date
        fail "Event #{event.event_id.inspect} has no start or end dates. It cannot be sync'd to PSC."
      end

      sort_key = "#{start_date}:#{'%03d' % event.event_type_code.to_s}"

      redis.hmset(ekey,
                  'completed', event.completed?,
                  'end_date', event.event_end_date,
                  'event_id', event.public_id,
                  'event_type_code', event.event_type_code,
                  'event_type_label', event.label,
                  'recruitment_arm', study_arm_for(participant),
                  'sort_key', sort_key,
                  'start_date', start_date,
                  'status', status_for(event))

      redis.sadd(lkey, event.public_id)
    end

    def cache_contact_link(contact_link, contact, event, participant)
      return unless should_cache_event?(event)

      lkey = sync_key['link_contact', contact_link.public_id]

      sort_key = "#{event.public_id}:#{contact.contact_date}"

      redis.pipelined do |r|
        r.hmset(lkey,
                'status', status_for(contact_link),
                'contact_link_id', contact_link.public_id,
                'event_id', event.public_id,
                'contact_id', contact.public_id,
                'contact_date', contact.contact_date,
                'sort_key', sort_key)

        link_key = ['p', participant.public_id,
                    'link_contacts', event.public_id]

        r.sadd(sync_key[*link_key], contact_link.public_id)
      end
    end

    ##
    # @private
    def should_cache_event?(event)
      Event::EVENTS_FOR_PSC.include?(event.event_type_code)
    end

    ##
    # @private
    def status_for(model)
      model.new_record? ? 'new' : 'changed'
    end

    ##
    # @private
    def study_arm_for(participant)
      participant.low_intensity? ? 'lo' : 'hi'
    end

    ##
    # @private
    def instrument_status(instrument)
      instrument.instrument_status.to_s.downcase
    end
  end
end
