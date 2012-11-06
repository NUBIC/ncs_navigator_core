class Api::NcsCodesController < ApiController
  def index
    if stale?(:last_modified => NcsCode.last_modified)
      render :json => NcsCode.all, :serializer => NcsCodeCollectionSerializer
    end
  end
end
