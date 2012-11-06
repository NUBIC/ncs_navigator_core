class ProviderSerializer < ActiveModel::Serializer
  attribute :name_practice, :key => :name
  attribute :provider_id, :key => :location
  attributes :practice_num, :recruited

  def practice_num
    object.pbs_list.try(:practice_num)
  end

  def recruited
    # Providers schema expects a boolean.
    !!object.recruited?
  end
end
