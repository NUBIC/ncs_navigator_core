require 'aker/cas_cli'
require 'ncs_navigator/core'
require 'ncs_navigator/warehouse'
require 'patient_study_calendar'

module Field
  ##
  # Augments {Superposition} with code to sync its contents with a PSC instance
  # via {NcsNavigator::Core::Warehouse::OperationalImporterPscSync}.
  #
  # There are three public methods:
  #
  # 1. {#login_to_psc}
  # 2. {#load_for_sync}
  # 3. {#sync_with_psc}
  #
  # {#sync_with_psc} requires the results of {#login_to_psc} and
  # {#load_for_sync}, so it invokes them.
  module PscSync
    include NcsNavigator::Core::Warehouse

    ##
    # Set this to use a non-global Aker configuration for CAS communication.
    attr_accessor :aker_configuration

    ##
    # The {Psc::SyncLoader} used to perform the sync.  This is set by
    # {#prepare_for_sync}.
    attr_accessor :sync_loader

    ##
    # The PSC importer.  Set by {#prepare_for_sync}.
    attr_accessor :psc_importer

    ##
    # The username for whom these changes are being synced.
    #
    # @see PatientStudyCalendar#responsible_user
    attr_accessor :responsible_user

    ##
    # A procedure that generates Redis keys.  Set by {#prepare_for_sync}.
    attr_accessor :keygen

    ##
    # Defaults self.aker_configuration to the global Aker configuration.
    def aker_configuration
      @aker_configuration || Aker.configuration
    end

    ##
    # Logs into PSC using Cases' machine account.  Returns a
    # {PatientStudyCalendar} instance on success, raises an error on failure.
    #
    # {#responsible_user} must be set before invoking this method.  If
    # {#responsible_user} is nil, this method will raise an error.
    def login_to_psc
      raise "responsible_user is not set" unless responsible_user

      cas_cli = Aker::CasCli.new(aker_configuration)
      username, password = NcsNavigatorCore.machine_account_credentials
      user = cas_cli.authenticate(username, password)

      raise "Authentication as #{username} failed" unless user

      PatientStudyCalendar.new(user).tap do |psc|
        psc.responsible_user = responsible_user
      end
    end

    ##
    # Builds objects and sets up a CAS session.
    def prepare_for_sync(merge)
      started = Time.now.to_f

      self.keygen = lambda do |*c|
        ['merge', merge.id, started, c].flatten.join(':')
      end

      self.sync_loader = Psc::SyncLoader.new(keygen)

      config = ImportConfiguration.new(logger)
      psc = login_to_psc
      self.psc_importer = OperationalImporterPscSync.new(psc, config, keygen)
    end

    def load_for_sync
      current_participants.each do |p|
        sync_loader.cache_participant(p)
      end

      events = load_events
      contact_links = load_contact_links

      events.each do |e|
        sync_loader.cache_event(e, e.participant)
      end

      contact_links.each do |cl|
        sync_loader.cache_contact_link(cl, cl.contact, cl.event, cl.participant)
      end
    end

    # Runs {OperationalImporterPscSync#import}.
    #
    # On error, {OperationalImporterPscSync#import} raises exceptions; this
    # method just lets them bubble up the stack.  A normal return from this
    # method signifies sync success.
    #
    # @return void
    def sync_with_psc
      load_for_sync
      psc_importer.import
    end

    ##
    # Loads events and associated entities used by Psc::SyncLoader.
    #
    # @private
    def load_events
      Event.includes(:participant).where(:id => current_events.map(&:id))
    end

    ##
    # Loads associations used by the PSC sync loader.
    #
    # @private
    def load_contact_links
      cs = current_contacts.map(&:id)
      es = current_events.map(&:id)
      is = current_instruments.map(&:id)

      # Find all ContactLinks that involve any combination of the above entities.
      t = ContactLink.arel_table

      cond = %w(contact_id event_id instrument_id).zip([cs, es, is]).map do |k, ids|
        t[k].in(ids).or(t[k].eq(nil))
      end.inject(&:and)

      ContactLink.includes([:contact, :instrument, {:event => :participant}]).where(cond)
    end

    ##
    # Just enough configuration for OperationalImporterPscSync.
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
