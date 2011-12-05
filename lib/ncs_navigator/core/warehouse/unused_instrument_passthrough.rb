require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  class UnusedInstrumentPassthrough
    def initialize(wh_config)
      @wh_config = wh_config
    end

    def import
      create_emitter.emit_xml
    end

    def create_emitter
      @emitter ||= NcsNavigator::Warehouse::XmlEmitter.new(
        @wh_config, Rails.root + 'tmp/unused_imported_instrument_tables.xml',
        :zip => false, :'include-pii' => true, :tables => unused_tables)
    end

    private

    def unused_tables
      instr_tables = ::NcsNavigatorCore.mdes.transmission_tables.
        select { |t| t.instrument_table? }.collect { |t| t.name }

      used_tables = Survey.most_recent_for_each_title.collect { |s|
        s.mdes_table_map.values.collect { |tc| tc[:table] }
      }.flatten

      instr_tables - used_tables
    end
  end
end
