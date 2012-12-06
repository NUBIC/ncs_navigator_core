require 'ncs_navigator/core'

module NcsNavigator::Core
  ##
  # Loads a CSV containing participant IDs in order to check/update whether they
  # are "being_followed".
  #
  # The CSV must have a `p_id` column which contains the P_IDs for all
  # participants which are expected to be followed. It may also contain an
  # `intensity` column containing "Hi" or "Lo" for each participant.
  # If `intensity` is missing, it will assume all participants should be "Hi".
  class FollowedParticipantChecker
    def initialize(csv_io)
      @csv_io = csv_io
    end

    def expected_participants
      @expected_participants ||= load_expected_participants
    end

    def load_expected_participants
      csv = Rails.application.csv_impl.new(@csv_io, :headers => true, :header_converters => :symbol)
      rows = csv.read

      intensity_expected = csv.headers.include?(:intensity)

      rows.collect { |row|
        ExpectedParticipant.new.tap { |p|
          p.p_id = row[:p_id]
          p.set_intensity(row, intensity_expected)
        }
      }
    end
    private :load_expected_participants

    def cases_followed_participants
      @cases_followed_participants ||= Participant.where(:being_followed => true).all
    end

    def differences
      @differences ||= determine_differences
    end

    def determine_differences
      all_pids = [expected_participants + cases_followed_participants].flatten.collect(&:p_id).uniq

      pairs = all_pids.each_with_object([]) { |p_id, acc|
        acc << [
          expected_participants.find { |p| p.p_id == p_id },
          cases_followed_participants.find { |p| p.p_id == p_id } || Participant.where(:p_id => p_id).first
        ]
      }

      pairs.each_with_object({}) { |(expected, cases), diff|
        if expected && cases
          if cases.being_followed
            # No problems
          else
            register_difference(diff, 'Expected to be followed but not followed in Cases', expected.p_id)
          end

          if cases.intensity == expected.intensity
            # No problems
          elsif expected.intensity == :low
            register_difference(diff, 'Expected to be Low but is High in Cases', expected.p_id)
          else
            register_difference(diff, 'Expected to be High but is Low in Cases', expected.p_id)
          end
        elsif expected
          register_difference(diff, 'Completely missing from Cases', expected.p_id)
        elsif cases
          register_difference(diff, 'Unexpectedly followed in Cases', cases.p_id)
        end
      }
    end
    private :determine_differences

    def register_difference(diff, message, p_id)
      (diff[message] ||= []) << p_id
    end
    private :register_difference

    ##
    # Prints a human-readable report about mismatches between the current
    # followed participants and the contents of the CSV.
    def report(out=$stderr)
      if differences.empty?
        out.puts "Everything matches exactly."
      else
        differences.each do |message, p_ids|
          out.puts message
          p_ids.each do |p_id|
            out.puts "* #{p_id}"
          end
        end
      end
    end

    ##
    # Changes any mismatched participants to the followedness/state given in
    # the CSV.
    def update!
    end

    class ExpectedParticipant
      attr_accessor :p_id, :intensity

      def being_followed
        true
      end

      def errors
        @errors ||= []
      end

      def set_intensity(from_row, explicit_intensity_expected)
        if explicit_intensity_expected
          self.intensity =
            case from_row[:intensity]
            when /hi/i
              :high
            when /lo/i
              :low
            end
          (errors << "Participant #{p_id} does not have an intensity value") unless self.intensity
        else
          self.intensity = :high
        end
      end
    end
  end
end