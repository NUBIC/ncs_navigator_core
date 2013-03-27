class ProviderSerializer < ActiveModel::Serializer
  attribute :name_practice, :key => :name
  attribute :provider_id, :key => :location
  attributes :practice_num, :recruited, :address_one, :unit
  
  def practice_num
    object.pbs_list.try(:practice_num)
  end

  def recruited
    # Providers schema expects a boolean.
    !!object.recruited?
  end

  def address_one
    object.address.try(:address_one)
  end

  def unit
    object.address.try(:unit)
  end
end
