class NcsNavigator::Core::PscRegistrationProcessor
  def initialize(pid_io, psc, wh_config)
    @csv ||= Rails.application.csv_impl.read(pid_io, :headers => true, :header_converters => :symbol)
    @psc = psc
    @wh_config = wh_config
    @sync_loader = Psc::SyncLoader.new(keygen)
  end

  def register_to_psc
    @wh_config.shell.say_line("Preparing records for PSC sync...")
    p_ids = []
    @csv.each do |row|
      next if row.header_row?
      p_ids << row[:p_id]
    end
    process_participants(p_ids)
    NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(@psc, @wh_config, keygen).import('psc_registration')
  end

  def keygen
    @keygen ||= lambda do |*c|
      ["psc_registration:#{Date.today}", c].flatten.join(":")
    end
  end

  def process_participants(p_ids)
    participants = Participant.where(:p_id => p_ids)
    participants.each do |p|
      @sync_loader.cache_participant(p)
      p.events.each do |e|
        @sync_loader.cache_event(e, e.participant)
        e.contact_links.each do |cl|
          @sync_loader.cache_contact_link(cl, cl.contact, cl.event, cl.participant)
        end
      end
    end
  end
  private :process_participants
end