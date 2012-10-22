module Field
  ##
  # Wraps a hash of the form
  #
  #     {
  #       ModelClass => {
  #         "public_id" => internal_id,
  #         ...
  #       },
  #       ...
  #     }
  #
  # with convenience accessors that perform nil checks.
  #
  #
  # Usage
  # =====
  #
  #     map = IdMap.new(id_hash)
  #     map.id_for(ModelClass, 'public_id')  # => internal_id
  #
  # If either the model or public ID are not in the map, #id_for will return
  # nil.
  class IdMap
    def initialize(hash)
      @hash = hash
    end

    def id_for(model, public_id)
      map = @hash[model]
      return nil unless map

      map[public_id]
    end
  end
end
