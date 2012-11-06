class Api::ProvidersController < ApiController
  def index
    if stale?(:last_modified => Provider.last_modified)
      render :json => Provider.includes(:pbs_list)
    end
  end
end
