class NcsCodeCollectionSerializer < ActiveModel::ArraySerializer
  def as_json(*)
    super.tap do |h|
      h['mdes_version'] = NcsNavigatorCore.configuration.mdes.version
      h['mdes_specification_version'] = NcsNavigatorCore.configuration.mdes.specification_version
    end
  end
end
