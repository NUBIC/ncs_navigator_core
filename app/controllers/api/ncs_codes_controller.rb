class Api::NcsCodesController < ApplicationController
  respond_to :json

  def index
    client_id = request.headers['X-Client-ID']

    if client_id.blank?
      render :nothing => true, :status => :bad_request
    end

    if stale?(:last_modified => NcsCode.last_modified)
    end
  end
end
