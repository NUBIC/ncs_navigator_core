class Api::NcsCodesController < ApiController
  def index
    if stale?(:last_modified => NcsCode.last_modified)
      respond_with NcsCode.all, :serializer => NcsCodeCollectionSerializer
    end
  end
end
