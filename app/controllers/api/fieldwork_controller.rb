class Api::FieldworkController < ApplicationController
  respond_to :json

  def create
    fw = Fieldwork.create

    respond_to do |wants|
      wants.json do
        headers['Location'] = api_fieldwork_path(fw.id)
        render :nothing => true, :status => :created
      end
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
