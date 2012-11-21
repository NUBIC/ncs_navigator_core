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
      return unless event.event_type_code > 0

      ekey = sync_key['event', event.public_id]
      lkey = sync_key['p', participant.public_id, 'events']

      sort_key = "#{event.event_start_date}:#{'%03d' % event.event_type_code.to_s}"

      redis.hmset(ekey,
                  'end_date', event.event_end_date,
                  'event_id', event.public_id,
                  'event_type_code', event.event_type_code,
                  'event_type_label', event.label,
                  'recruitment_arm', study_arm_for(participant),
                  'sort_key', sort_key,
                  'start_date', event.event_start_date,
                  'status', status_for(event))

      redis.sadd(lkey, event.public_id)
    end

    def cache_contact_link(contact_link, contact, instrument, event, participant)
      lkey = sync_key['link_contact', contact_link.public_id]

      instrument_type_code = instrument.try(:instrument_type_code)
      sort_key = "#{event.public_id}:#{contact.contact_date}"
      sort_key << ":#{'%03d' % instrument_type_code.to_s}" if instrument_type_code

      redis.pipelined do |r|
        r.hmset(lkey,
                'status', status_for(contact_link),
                'contact_link_id', contact_link.public_id,
                'event_id', event.public_id,
                'contact_id', contact.public_id,
                'contact_date', contact.contact_date,
                'sort_key', sort_key)

        if instrument
          r.hmset(lkey,
                  'instrument_type', instrument_type_code,
                  'instrument_id', instrument.public_id,
                  'instrument_status', instrument_status(instrument))
        end

        link_key = if instrument
                    ['p', participant.public_id,
                      'link_contacts_with_instrument', instrument.public_id]
                   else
                     ['p', participant.public_id,
                       'link_contacts_without_instrument', event.public_id]
                   end

        r.sadd(sync_key[*link_key], contact_link.public_id)
      end
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
