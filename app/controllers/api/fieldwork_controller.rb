# encoding: utf-8

class Api::FieldworkController < ApplicationController
  respond_to :json

  def create
    begin
      fw = Fieldwork.from_psc(params, psc, current_staff_id).tap(&:save!)

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
      fw.update_attribute(:received_data, request.body.read)
    ensure
      request.body.rewind
    end

    Resque.enqueue(NcsNavigator::Core::Jobs::MergeFieldwork, fw.id)
    headers['Location'] = api_fieldwork_path(fw.id)
    render :nothing => true, :status => :accepted
  end

  def show
    fw = Fieldwork.find(params['id'])

    respond_with fw
  end
end