require 'ncs_navigator/core/warehouse'

require 'ncs_navigator/core/warehouse/response_set_to_warehouse'

module NcsNavigator::Core::Warehouse
  ##
  # Incrementally builds and yields MDES records for every ResponseSet
  # in the system.
  class InstrumentEnumerator
    include Enumerable

    def self.create_transformer(wh_config)
      NcsNavigator::Warehouse::Transformers::EnumTransformer.new(wh_config, new)
    end

    def each
      ResponseSet.find_each do |rs|
        rs.to_mdes_warehouse_records.each do |record|
          yield record
        end
      end
    end
  end
end
