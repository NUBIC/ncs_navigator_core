require 'ncs_navigator/core'

class NcsNavigator::Core::Psc::ScheduledActivityReport
  ##
  # Deep-merges rows having the same public contact ID.
  module Merge
    ##
    # Replaces the contents of #rows with the merge result.  #merge! preserves
    # row order.
    def merge!
      merged = ActiveSupport::OrderedHash.new

      @event_map = {}
      @instrument_map = Hash.new([])

      rows.each do |r|
        id = r.contact.try(:public_id)

        @event_map[r.contact] ||= []

        if r.event
          @event_map[r.contact] << r.event

          if r.instrument
            unless @instrument_map.has_key?([r.contact, r.event])
              @instrument_map[[r.contact, r.event]] = []
            end

            @instrument_map[[r.contact, r.event]] << r.instrument
          end
        end

        merged[id] ||= r
      end

      self.rows = merged.values
    end

    def events_for(contact)
      @event_map[contact]
    end

    def instruments_for(contact, event)
      @instrument_map[[contact, event]]
    end
  end
end
