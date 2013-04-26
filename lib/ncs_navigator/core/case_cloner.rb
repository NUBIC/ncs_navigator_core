require 'ncs_navigator/core'

module NcsNavigator::Core
  class CaseCloner
    ##
    # The cloner works by walking record associations recursively, starting
    # from Participant. For each association it encounters, it will clone
    # and recurse over the record on the other end IFF its type is in this list.
    MODELS_TO_CLONE = %w(
      Participant
      ParticipantLowIntensityStateTransition
      ParticipantHighIntensityStateTransition
      ParticipantPersonLink
      ParticipantConsent
      ParticipantConsentSample
      Person
      PersonRace
      ContactLink
      Contact
      Event
      Instrument
      ResponseSet
      Response
      DwellingUnit
      DwellingHouseholdLink
      HouseholdUnit
      HouseholdPersonLink
      PersonProviderLink
      InstitutionPersonLink
      Telephone
      Address
      Email
      PpgDetail
      PpgStatusHistory
      SampledPersonsIneligibility
      Sample
      SpecimenReceiptConfirmation
      Specimen
      ShipSpecimen
      SpecimenPickup
      NonInterviewReport
      DwellingUnitTypeNonInterviewReport
      NoAccessNonInterviewReport
      RefusalNonInterviewReport
      VacantNonInterviewReport
      LegacyInstrumentDataRecord
      LegacyInstrumentDataValue
    )

    UNIVERSAL_NON_COPIED_ATTRIBUTES = %w(id updated_at created_at lock_version access_code)

    INCLUDES = {
      :participant_person_links => {
        :person => {
          :addresses => [],
          :emails => [],
          :telephones => [],
          :contact_links => { :event => [], :contact => [], :instrument => { :response_sets => [:responses] }},
          :races => [],
          :household_person_links => :household_unit,
          :participant_person_links => :participant,
          :institution_person_links => [],
          :person_provider_links => [],
          :sampled_persons_ineligibilities => []
        }
      },
      :ppg_details => [],
      :ppg_status_histories => [],
      :low_intensity_state_transition_audits => [],
      :high_intensity_state_transition_audits => [],
      :participant_consents => [:participant_consent_samples],
      :participant_consent_samples => [],
      :events => { :contact_links => { :contact => [], :instrument => { :response_sets => :responses } } },
      :response_sets => [:responses]
    }

    def initialize(p_id)
      @root_p_id = p_id or fail "Please specify a p_id"
    end

    ##
    # @return [Array<Participant>] the specified participant to clone, plus
    #   all participants related to it (via ParticipantPersonLinks) one level
    #   deep.
    def source_participants
      @source_participants ||= find_source_participants
    end

    def find_source_participants
      participant_ids = Participant.find_by_sql([<<-SQL, @root_p_id]).collect(&:id)
        SELECT DISTINCT other.participant_id AS id
        FROM participants root
          INNER JOIN participant_person_links root_persons ON root.id = root_persons.participant_id
          INNER JOIN participant_person_links other ON root_persons.person_id = other.person_id
        WHERE root.p_id = ?
      SQL

      Participant.where(:id => participant_ids).includes(INCLUDES).all
    end
    private :find_source_participants

    ##
    # Clone just the records in Cases for the given participant
    #
    # @return [Hash<Participant, Participant>] a mapping from each source
    #   participant to its corresponding clone.
    def clone_cases_side
      source_participants.each_with_object({}) { |p, result| result[p] = clone_record(p) }
    end

    def sync_to_psc(user, cloned_participants)
      sync_loader = ::Psc::SyncLoader.new(psc_sync_keygen)
      Rails.logger.debug "Setting up for PSC sync using prefix #{psc_sync_keygen['']}"

      # Load the information for syncing
      cloned_participants.reject { |p| p.p_type_code == 6 }.each do |p|
        Rails.logger.debug("Recording cloned participant #{p.p_id} for PSC sync")

        sync_loader.cache_participant(p)

        p.events.each do |event|
          sync_loader.cache_event(event, p)
        end

        p.events.collect(&:contact_links).flatten.uniq.each do |cl|
          sync_loader.cache_contact_link(cl, cl.contact, cl.event, p)
        end
      end

      # execute the sync
      Rails.logger.debug("Executing PSC sync for #{sync_loader.cached_participant_ids.inspect}")
      NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(
        PatientStudyCalendar.new(user),
        ImportConfiguration.new(Rails.logger),
        psc_sync_keygen
      ).import(PaperTrail.whodunnit) # use audit information from outside
    end

    ##
    # Clone the records in Cases for the participant, then sync the new records
    # to PSC. Returns same mapping as {#clone_cases_side}.
    def clone(user)
      Participant.transaction do
        cases_side = clone_cases_side

        sync_to_psc(user, clone_cases_side.values)

        cases_side
      end
    end

    private

    def cloned_record_cache
      @cloned_records ||= {}
    end

    def record_key(record)
      [record.class.name, '#', record.id].join
    end

    def clone_record(record, log_depth=0)
      return unless record
      unless MODELS_TO_CLONE.include?(record.class.name)
        log_at log_depth, "#{record.class} is not a model to be cloned; using source value"
        return record
      end

      key = record_key(record)
      log_at log_depth, "Cloning #{key}"
      if cloned_record_cache[key]
        cloned_record_cache[key].tap do |clone|
          msg =
            if clone.persisted?
              "* returning already-created clone #{record_key(clone)}"
            else
              "* returning in-progress clone"
            end

          log_at log_depth, msg
        end
      else
        do_clone = lambda {
          clone = record.class.new
          # pre-cache the new record to avoid circular recursion
          cloned_record_cache[key] = clone

          copy_scalar_values(record, clone, log_depth)
          clone_single_value_association(:belongs_to, record, clone, log_depth)

          log_at log_depth, "- saving new #{clone.class}"
          clone.save!

          clone_has_many(record, clone, log_depth)
          clone_single_value_association(:has_one, record, clone, log_depth)

          log_at log_depth, "+ created new clone #{record_key(clone)}"
          clone
        }
        if record.class.respond_to?(:importer_mode)
          record.class.importer_mode do
            do_clone.call
          end
        else
          do_clone.call
        end
      end
    end

    def copy_scalar_values(record, clone, log_depth)
      skips = UNIVERSAL_NON_COPIED_ATTRIBUTES +
        record.class.reflect_on_all_associations(:belongs_to).collect(&:association_foreign_key) +
        [public_id_field_or_nil(record)].compact
      scalar_attributes = record.attributes.reject { |name, value| skips.include?(name) || value.nil? }
      log_at log_depth, "- copying scalar attribute#{'s' unless scalar_attributes.keys.size == 1} #{scalar_attributes.keys.inspect}"
      scalar_attributes.each do |name, value|
        clone.send("#{name}=", value)
      end
    end

    def public_id_field_or_nil(record)
      if record.class.respond_to?(:public_id_field)
        record.class.public_id_field.to_s
      end
    end

    def clone_has_many(record, clone, log_depth)
      associations = record.class.reflect_on_all_associations(:has_many).
        # no point in traversing :through associations; they'll be handled the long way
        reject { |assoc| assoc.options[:through] }.
        # don't change versions in clone
        reject { |assoc| assoc.name == :versions }.
        # Break loop, maybe.
        reject { |assoc| assoc.active_record == Contact && assoc.name == :contact_links }.
        each do |assoc|
        log_at log_depth, "- recursing for has_many #{assoc.name.inspect}"

        source_collection = record.send(assoc.name)
        clone.send(assoc.name).tap do |clone_assoc_proxy|
          source_collection.each do |source_value|
            clone_assoc_proxy << clone_record(source_value, log_depth + 1)
          end
        end

        log_at log_depth, "- done with #{assoc.name.inspect}"
      end
    end

    def clone_single_value_association(macro, record, clone, log_depth)
      associations = record.class.reflect_on_all_associations(macro).
        # exclude Surveyor's weird, invented "User" association
        reject { |assoc| assoc.active_record == ResponseSet && assoc.name == :user }.
        # Instrument#contact_link is a malformed association -- there are actually many CLs for an instrument potentially
        reject { |assoc| assoc.active_record == Instrument && assoc.name == :contact_link }
      associations.each do |assoc|
        log_at log_depth, "- recursing for #{assoc.macro} #{assoc.name.inspect}"

        source_value = record.send(assoc.name)
        unless source_value.nil?
          log_at log_depth, "- source is #{record_key(source_value)}"
          clone.send("#{assoc.name}=", clone_record(source_value, log_depth + 1))
        end

        log_at log_depth, "- done with #{assoc.name.inspect}"
      end
    end

    def log_at(log_depth, message)
      Rails.logger.debug ['|   ' * log_depth, message].join
    end

    def psc_sync_keygen
      @psc_sync_keygen ||= begin
        # needs to be outside the lambda, otherwise the random value changes
        # on every invocation.
        prefix = ['clone', @root_p_id, SecureRandom.hex].join('_')
        lambda { |*c|
          ([prefix] + c).join(':')
        }
      end
    end

    ##
    # Just enough configuration for OperationalImporterPscSync.
    #
    # Copied from Field::PscSync. TODO: eliminate the wh_config dependency in OperationalImporterPscSync.
    #
    # @private
    class ImportConfiguration
      attr_reader :log
      attr_reader :shell

      def initialize(logger)
        @log = logger
        @shell = NcsNavigator::Warehouse::UpdatingShell::Quiet.new
      end
    end
  end
end
