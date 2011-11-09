INSTRUMENT_EVENT_CONFIG  = YAML.load(File.read("#{Rails.root}/config/instrument_event_map.yml"))
PSC_SEGMENT_EVENT_CONFIG = YAML.load(File.read("#{Rails.root}/config/psc_segment_event_map.yml"))