class ApiController < ApplicationController
  # All API endpoints respond to JSON.
  respond_to :json

  # All API endpoints require a client ID.
  before_filter do |controller|
    client_id = controller.client_id

    if client_id.blank?
      render :json => { 'error' => 'Client ID missing' }, :status => :bad_request
    end
  end

  ##
  # Retrieves the supplied client ID.
  def client_id
    request.headers['X-Client-ID']
  end
end
