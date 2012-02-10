class Api::FieldworkController < ApplicationController
  respond_to :json

  def update
    fw = Fieldwork.for(params['id'])

    begin
      fw.received_data = request.body.read
      fw.save
    ensure
      request.body.rewind
    end

    headers['Location'] = api_fieldwork_path(fw.id)
    render :nothing => true, :status => :accepted
  end

  def show
    fw = Fieldwork.find(params['id'])

    respond_with fw.received_data
  end
end
