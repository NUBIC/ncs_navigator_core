class Api::CodeListsController < ApiController
  def index
    cc = Field::CodeCollection.new

    if stale?(:last_modified => cc.last_modified)
      cc.load_codes
      respond_with cc, :serializer => Field::CodeCollectionSerializer
    end
  end
end
