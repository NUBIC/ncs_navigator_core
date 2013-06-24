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
    MESSAGES = {
      :expected_followed     => 'Expected to be followed but not followed in Cases',
      :expected_not_followed => 'Unexpectedly followed in Cases',
      :expected_low          => 'Expected to be Low but is High in Cases',
      :expected_high         => 'Expected to be High but is Low in Cases',
      :missing_from_cases    => 'Completely missing from Cases'
    }

    def initialize(csv_filename, options={})
      @csv_filename = csv_filename.to_s

      @quiet = options.delete(:quiet)
    end

    def expected_participants
      @expected_participants ||= load_expected_participants
    end

    def expected_p_ids
      expected_participants.collect(&:p_id)
    end

    def load_expected_participants
      File.open(@csv_filename) do |csv_io|
        csv = Rails.application.csv_impl.new(csv_io, :headers => true, :header_converters => :symbol)
        rows = csv.read

        unless csv.headers.include?(:p_id)
          fail "#{@csv_filename} has no p_id column"
        end

        intensity_expected = csv.headers.include?(:intensity)

        rows.collect { |row|
          ExpectedParticipant.new.tap { |p|
            p.p_id = row[:p_id]
            p.set_intensity(row, intensity_expected)
          }
        }
      end
    end
    private :load_expected_participants

    def cases_followed_participants
      @cases_followed_participants ||= Participant.where("being_followed = true AND p_type_code != 6").all
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
        next if expected && !expected.errors.empty?

        if expected && cases
          if cases.being_followed
            # No problems
          else
            register_difference(diff, :expected_followed, expected.p_id)
          end

          if cases.intensity == expected.intensity
            # No problems
          elsif expected.intensity == :low
            register_difference(diff, :expected_low, expected.p_id)
          else
            register_difference(diff, :expected_high, expected.p_id)
          end
        elsif expected
          register_difference(diff, :missing_from_cases, expected.p_id)
        elsif cases
          register_difference(diff, :expected_not_followed, cases.p_id)
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
      errors = expected_participants.collect(&:errors).flatten
      unless errors.empty?
        out.puts "CSV Errors:"
        errors.each do |error|
          out.puts "* #{error}"
        end
        out.puts
      end

      if differences.empty?
        out.puts "Everything matches exactly."
      else
        differences.each do |code, p_ids|
          out.puts MESSAGES[code]
          p_ids.sort.each do |p_id|
            out.puts "* #{p_id}"
          end
        end
      end
    end

    UPDATERS = {
      :expected_followed => lambda { |participant|
        participant.tap { |p| p.being_followed = true }.save!
      },
      :expected_not_followed => lambda { |participant|
        participant.tap { |p| p.being_followed = false }.save!
      }
    }

    ##
    # Changes any mismatched participants to the followedness/state given in
    # the CSV.
    def update!
      count = differences.values.flatten.size
      done = 0

      start_whodunnit = PaperTrail.whodunnit
      begin
        PaperTrail.whodunnit = "FollowedParticipantChecker(#{File.basename @csv_filename})"

        Participant.transaction do
          UPDATERS.each do |code, updater|
            next unless differences[code]

            differences[code].each do |p_id|
              done += 1
              console_say "\rProcessing #{done}/#{count} correction#{'s' unless count == 1}."

              updater[ Participant.where(:p_id => p_id).first ]
            end
          end
        end
      ensure
        PaperTrail.whodunnit = start_whodunnit
      end

      console_say "\rCompleted #{count} correction#{'s' unless count == 1}.          \n"
    end

    def console_say(s)
      $stderr.write(s) unless @quiet
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
