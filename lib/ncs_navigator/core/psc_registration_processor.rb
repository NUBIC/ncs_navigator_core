class NcsNavigator::Core::PscRegistrationProcessor
  def initialize(pid_io, psc, wh_config)
    @pid_io = pid_io
    @psc = psc
    @wh_config = wh_config
    @sync_loader = Psc::SyncLoader.new(keygen)
  end

  def csv
    @csv ||= Rails.application.csv_impl.read(@pid_io, :headers => true, :header_converters => :symbol)
  end

  def register_to_psc
    csv.each do |row|
      next if row.header_row?
      process_participant(row[:p_id])
    end

    wh_config.shell.say_line("Preparing records for PSC sync...")
    NcsNavigator::Core::Warehouse::OperationalImporterPscSync.new(@psc, @wh_config, keygen).import
  end

  def keygen
    @keygen ||= lambda do |*c|
      ['psc_registration', c].flatten.join(':')
    end
  end

  def process_participant(p_id)
    if participant = find_participant(p_id)
      @sync_loader.cache_participant(participant)
      participant.events.each do |e|
        @sync_loader.cache_event(e, e.participant)
        event.contact_links.each do |cl|
          @sync_loader.cache_contact_link(cl, cl.contact, cl.event, cl.participant)
        end
      end
    end
  end
  private :process_participant

  def find_participant(p_id)
    participant = Participant.where(:p_id => p_id).first
    unless participant
      return nil
    end
    participant
  end
  private :find_participant
end