require 'ncs_navigator/core'

module NcsNavigator::Core::Warehouse
  module UnusedPassthrough
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
        :zip => false, :'include-pii' => true, :tables => unused_tables)
    end

    def path
      @path ||= Rails.root + "importer_passthrough/#{filename}-#{timestamp}.xml"
    end

    protected

    def timestamp
      Time.now.getutc.iso8601.gsub(/[^\d]/, '')
    end
  end
end
