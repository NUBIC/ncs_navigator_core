class Api::FieldworkController < ApplicationController
  respond_to :json

  def create
    begin
      fw = Fieldwork.create!(params)

      respond_to do |wants|
        wants.json do
          headers['Location'] = api_fieldwork_path(fw.id)
          render :json => fw
        end
      end
    rescue ActiveRecord::RecordInvalid
      render :nothing => true, :status => :bad_request
    end
  end

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

    respond_with fw
  end
end
