class InstrumentEventMap

  ##
  # For a given event, return the filenames of all the Instruments/Surveys that match
  # from the MDES Instrument and Event Map
  # 
  # @param [String] - the name of the event (e.g. Pregnancy Screener)
  # @return [Array, <String>] - filenames for that event
  def self.instruments_for(event)
    return [] if event.nil?
    event = PatientStudyCalendar.map_psc_segment_to_mdes_event(event)
    result = []
    INSTRUMENT_EVENT_CONFIG.each do |ie|
      result << ie["filename"] if ie["event"].include?(event)
    end
    result
  end
  
  ##
  # A list of all the known event names.
  # @return [Array, <String>]
  def self.events
    INSTRUMENT_EVENT_CONFIG.collect { |ie| ie["event"].split(";") }.flatten.collect { |e| e.strip }.uniq.sort
  end
  
  ##
  # Get the current version number for this Instrument from the Instrumnnt and Event Map
  # @param [String]
  # @return [String]
  def self.version(filename)
    result = nil
    INSTRUMENT_EVENT_CONFIG.each do |ie|
      if filename =~ Regexp.new(ie["filename"])
        result = ie["version_number"]
        break
      end
    end
    result
  end
  
  ##
  # For the given filename, find the NcsCode from the INSTRUMENT_TYPE_CL1 Code List.
  # @param [String]
  # @return [NcsCode]
  def self.instrument_type(filename)
    result = nil
    INSTRUMENT_EVENT_CONFIG.each do |ie|
      if ie["filename"] == filename
        result = NcsCode.where(:list_name => 'INSTRUMENT_TYPE_CL1').where(:display_text => ie["name"]).first
        break
      end
    end
    result
  end
  
end