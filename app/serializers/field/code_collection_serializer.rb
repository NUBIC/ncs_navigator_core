module Field
  class CodeCollectionSerializer < ActiveModel::Serializer
    has_many :disposition_codes, :serializer => Mdes::DispositionCodeSerializer
    has_many :ncs_codes

    root false

    def attributes
      {}.tap do |h|
        h['mdes_version'] = NcsNavigatorCore.configuration.mdes.version
        h['mdes_specification_version'] = NcsNavigatorCore.configuration.mdes.specification_version
      end
    end
  end
end
