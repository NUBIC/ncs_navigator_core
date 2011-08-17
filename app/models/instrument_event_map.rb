class InstrumentEventMap

  def self.instruments_for(event)
    result = []
    INSTRUMENT_EVENT_CONFIG.each do |ie|
      result << ie["filename"] if ie["event"].include?(event)
    end
    result
  end
  
  def self.events
    INSTRUMENT_EVENT_CONFIG.collect { |ie| ie["event"].split(";") }.flatten.collect { |e| e.strip }.uniq.sort
  end
  
  def self.version(filename)
    result = nil
    INSTRUMENT_EVENT_CONFIG.each do |ie|
      if ie["filename"] == filename
        result = ie["version_number"]
        break
      end
    end
    result
  end
  
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