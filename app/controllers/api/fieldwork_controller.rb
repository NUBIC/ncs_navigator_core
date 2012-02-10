class Api::FieldworkController < ApplicationController
  respond_to :json

  def update
    id = params['id']

    save_response(id)

    headers['Location'] = api_fieldwork_path(id)
    render :nothing => true, :status => :accepted
  end

  def show
    respond_with response_for(params['id'])
  end

  private

  def save_response(id)
    File.open("#{Rails.root}/tmp/#{id}", 'w') do |f|
      f.write(request.body.read)
    end

    request.body.rewind
  end

  def response_for(id)
    File.read("#{Rails.root}/tmp/#{id}")
  end
end
