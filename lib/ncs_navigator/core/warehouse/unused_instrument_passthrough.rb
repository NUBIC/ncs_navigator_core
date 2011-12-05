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
        :zip => false, :'include-pii' => true, :tables => Survey.mdes_unused_instrument_tables)
    end
  end
end
