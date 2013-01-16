module Psc
  ##
  # This module contains representations of Cases entities implied by a set of
  # scheduled activities.
  module ImpliedEntities
    ##
    # Used to generate {InstrumentPlan} IDs.
    module Fingerprint
      def fingerprint
        concat = self.class.members.map do |m|
          v = send(m)

          v.respond_to?(:fingerprint) ? v.fingerprint : v.to_s
        end.join('')

        @fingerprint ||= Digest::SHA1.hexdigest(concat)
      end
    end

    ##
    # Used for implied entities that have a partial order, i.e. Instruments and
    # Surveys.
    module Comparable
      def <=>(other)
        order <=> other.order
      end
    end

    class ContactLink < Struct.new(:person, :contact, :event, :instrument)
    end

    class Contact < Struct.new(:scheduled_date, :person)
      include Fingerprint
    end

    class Event < Struct.new(:label, :ideal_date, :contact, :person)
      include Fingerprint
    end

    class Instrument < Struct.new(:survey, :referenced_survey, :name, :event, :person, :order)
      include Comparable
      include Fingerprint
    end

    class Person < Struct.new(:person_id)
      include Fingerprint
    end

    class Survey < Struct.new(:access_code, :participant_type, :order)
      include Comparable
      include Fingerprint
    end

    class SurveyReference < Struct.new(:access_code)
      include Fingerprint
    end
  end
end
