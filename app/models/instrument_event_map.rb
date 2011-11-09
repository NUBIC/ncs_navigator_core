class InstrumentEventMap

  # TODO: Map PSC Activities to Instrument File names !!!!

  ##
  # For a given event, return the filenames of all the Instruments/Surveys that match
  # from the MDES Instrument and Event Map
  # 
  # @param [String] - the name of the PSC segment (e.g. Lo-Intensity:Pregnancy Screener)
  # @return [Array, <String>] - filenames for that event
  def self.instruments_for(segment)
    return [] if segment.nil?
    event = PatientStudyCalendar.map_psc_segment_to_mdes_event(segment)
    result = []
    instruments.each do |ie|
      result << ie["filename"] if ie["event"].include?(event)
    end
    result
  end
  
  ##
  # A list of all the known event names.
  # @return [Array, <String>]
  def self.events
    instruments.collect { |ie| ie["event"].split(";") }.flatten.collect { |e| e.strip }.uniq.sort
  end
  
  ##
  # Get the current version number for this Instrument from the Instrumnnt and Event Map
  # @param [String]
  # @return [String]
  def self.version(filename)
    result = nil
    instruments.each do |ie|
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
    instruments.each do |ie|
      if ie["filename"] == filename
        result = NcsCode.where(:list_name => 'INSTRUMENT_TYPE_CL1').where(:display_text => ie["name"]).first
        break
      end
    end
    result
  end
  
  def self.instruments
    results = []
    with_specimens = NcsNavigatorCore.with_specimens
    INSTRUMENT_EVENT_CONFIG.each do |ie|
      filename = ie["filename"]      
      next if filename.include?("_DCI_") && with_specimens == "false"

      case NcsNavigatorCore.recruitment_type
      when "HILI"
        results << ie if filename.include?("HILI") || filename.include?("HI") || filename.include?("LI")
      when "PB"
        results << ie if filename.include?("PB")
      when "EH"
        results << ie if filename.include?("EH")
      end
    end
    results
  end
  
end