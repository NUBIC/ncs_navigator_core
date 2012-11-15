class DispositionCodeSerializer < ActiveModel::Serializer
  attributes :final_category, :sub_category, :disposition, :category_code,
    :interim_code, :final_code
end
