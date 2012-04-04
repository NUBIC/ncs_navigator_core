require 'ncs_navigator/core'

class NcsNavigator::Core::Psc::ScheduledActivityReport
  module Logging
    extend ActiveSupport::Concern

    included do
      set_callback :map_entities, :after do |r|
        r.logger.info { 'Entity mapping complete' }
      end

      set_callback :map_persons, :after do |r|
        r.with_map_result_analysis(:rows, :person) do |attempted, succeeded, failed|
          failed.each do |f|
            r.logger.warn { "Could not match subject ID #{f.person_id} to a person" }
          end

          r.logger.info { "Person search: #{attempted} attempted, #{succeeded} matched" }
        end
      end

      set_callback :map_events, :after do |r|
        r.with_map_result_analysis(:rows_with_events, :event) do |attempted, succeeded, failed|
          failed.each do |f|
            r.logger.warn { "Could not match event label #{f.event_label} to an event on subject ID #{f.person_id}" }
          end

          r.logger.info { "Event search: #{attempted} attempted, #{succeeded} matched" }
        end
      end

      set_callback :map_instruments, :after do |r|
        r.rows.each do |row|
          if row.instrument.try(&:new_record?)
            r.logger.info { "Using newly instantiated instrument for instrument label #{row.instrument_label}, subject ID #{row.person_id}" }
          end
        end

        r.with_map_result_analysis(:rows_with_instruments, :instrument) do |attempted, succeeded, failed|
          failed.each do |f|
            event_label = f.event_label || '(none)'
            instrument_label = f.instrument_label || '(none)'
            code = (f.survey_access_code if f.instrument_label) || '(none)'
            subject_id = f.person_id || '(none)'

            r.logger.warn do
              [ "Could not match instrument label #{instrument_label} to an instrument for",
                "subject ID #{subject_id},",
                "survey access code #{code},",
                "event label #{event_label}"
              ].join(' ')
            end
          end

          r.logger.info { "Instrument search: #{attempted} attempted, #{succeeded} matched" }
        end
      end

      set_callback :map_contacts, :after do |r|
        r.rows.each do |row|
          if row.contact.try(&:new_record?)
            r.logger.info { "Using newly instantiated contact for event label #{row.event_label}, subject ID #{row.person_id}" }
          end
        end
      end
    end

    module InstanceMethods
      def with_map_result_analysis(expected_set, expected_attr)
        expected = send(expected_set)
        failed = expected.reject { |r| r.send(expected_attr) }
        attempted = expected.length
        succeeded = attempted - failed.length

        yield attempted, succeeded, failed
      end
    end
  end
end
