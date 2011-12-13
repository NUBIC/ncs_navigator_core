require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  class UnusedInstrumentPassthrough
    def initialize(wh_config)
      @wh_config = wh_config
    end

    def import
      path.parent.mkpath
      create_emitter.emit_xml
    end

    def create_emitter
      @emitter ||= NcsNavigator::Warehouse::XmlEmitter.new(
        @wh_config, path,
        :zip => false, :'include-pii' => true, :tables => Survey.mdes_unused_instrument_tables)
    end

    def path
      @path ||= Rails.root + 'tmp/unused_imported_instrument_tables.xml'
    end
  end
end
