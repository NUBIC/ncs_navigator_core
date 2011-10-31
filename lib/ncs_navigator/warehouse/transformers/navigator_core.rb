require 'ncs_navigator/warehouse'
require 'ncs_navigator/warehouse/models/two_point_zero'

module NcsNavigator::Warehouse::Transformers
  class NavigatorCore
    include Database

    include NcsNavigator::Warehouse::Models::TwoPointZero

    bcdatabase :name => 'ncs_navigator_core'

    def self.direct_map(row, model)
      model.properties.inject({}) do |m, a|
        if row.respond_to?(a.name)
          m[a] = row.send(a.name)
        end
        m
      end
    end

    produce_records :people do |row|
      Person.new(
        direct_map(row, Person)
      )
    end
  end
end
