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
  
end