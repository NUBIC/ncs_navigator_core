# -*- coding: utf-8 -*-

class Api::FieldworkController < ApplicationController
  respond_to :json

  def create
    unless %w(client_id end_date start_date).all? { |k| params.has_key?(k) }
      render :nothing => true, :status => :bad_request and return
    end

    fw = Fieldwork.from_psc(params, psc, current_staff_id).tap(&:save!)

    respond_to do |wants|
      wants.json do
        headers['Location'] = api_fieldwork_path(fw.id)
        render :json => fw
      end
    end
  end

  def update
    fw = Fieldwork.for(params['id'])

    begin
      fw.update_attribute(:received_data, request.body.read)
    ensure
      request.body.rewind
    end

    NcsNavigator::Core::Fieldwork::MergeWorker.perform_async(fw.id)
    headers['Location'] = api_fieldwork_path(fw.id)
    render :nothing => true, :status => :accepted
  end

  def show
    fw = Fieldwork.find(params['id'])

    respond_with fw
  end
end
