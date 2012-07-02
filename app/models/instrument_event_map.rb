

class InstrumentEventMap

  # FIXME: PSC template activities should match MDES instruments
  def self.activity_to_instrument_name(activity)
    case activity
    when "Low-Intensity Birth Interview"
      "Birth Interview (LI)"
    else
      activity
    end
  end

  ##
  # For a given survey title (i.e. instrument filename), return the instrument name
  #
  # @param [String] - filename for the instrument whose name matches the activity
  # @return [String] - the name of the instrument (e.g. Pregnancy Probability Group Follow-Up Interview)
  def self.name_of_instrument(instrument_filename)
    InstrumentEventMap.instrument_map_value_for_filename(instrument_filename, "name")
  end

  ##
  # Get the current version number for this Instrument from the Instrumnnt and Event Map
  # @param [String]
  # @return [String]
  def self.version(instrument_filename)
    InstrumentEventMap.instrument_map_value_for_filename(instrument_filename, "version_number")
  end

  def self.instrument_map_value_for_filename(instrument_filename, value)
    result = nil
    instruments.each do |ie|
      if instrument_filename =~ Regexp.new(ie["filename"])
        result = ie[value]
        break
      end
    end
    result
  end

  ##
  # For a given MDES code list local code value, return the name of the instrument
  #
  # @param [String] - INSTRUMENT_TYPE_CL1 local code
  # @return [String] - name for the instrument
  def self.name_for_instrument_type(code)
    InstrumentEventMap.instrument_map_value_for_code(code, "name")
  end

  ##
  # For a given MDES code list local code value, return the filename of the instrument
  #
  # @param [String] - INSTRUMENT_TYPE_CL1 local code
  # @return [String] - filename for the instrument
  def self.filename_for_instrument_type(code)
    InstrumentEventMap.instrument_map_value_for_code(code, "filename")
  end

  def self.instrument_map_value_for_code(code, value)
    result = nil
    instruments.each do |ie|
      if code.to_i == ie["instrument_type"]
        result = ie[value]
        break
      end
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
  # For the given filename, find the NcsCode from the INSTRUMENT_TYPE_CL1 Code List.
  # @param [String]
  # @return [NcsCode]
  def self.instrument_type(filename)
    if filename.index(' ').to_i > 0
      sub = filename[filename.index(' '), filename.length]
      filename = filename.gsub(sub, '')
    end

    result = nil
    instruments.each do |ie|
      if ie["filename"] == filename
        result = NcsCode.where(:list_name => 'INSTRUMENT_TYPE_CL1').where(:display_text => ie["name"]).first
        break
      end
    end
    result
  end

  # TODO: use coded version that is not core specific from ini file
  #       recruitment_type_id
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