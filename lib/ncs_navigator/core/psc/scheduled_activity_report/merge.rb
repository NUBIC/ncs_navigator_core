require 'ncs_navigator/core'

class NcsNavigator::Core::Psc::ScheduledActivityReport
  module Merge
    def merge
      merged = ActiveSupport::OrderedHash.new

      event_map = Hash.new([])
      instrument_map = Hash.new([])

      rows.select(&:contact).each do |r|
        c = r.contact

        merged[c.public_id] ||= r

        if r.event
          e = r.event

          unless event_map.has_key?(c.public_id)
            event_map[c.public_id] = []
          end

          event_map[c.public_id] << e

          if r.instrument
            unless instrument_map.has_key?([c.public_id, e.public_id])
              instrument_map[[c.public_id, e.public_id]] = []
            end

            instrument_map[[c.public_id, e.public_id]] << r.instrument
          end
        end
      end

      [merged.values, event_map, instrument_map]
    end
  end
end
