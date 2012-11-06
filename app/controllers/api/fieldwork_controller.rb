# -*- coding: utf-8 -*-


class Api::FieldworkController < ApplicationController
  respond_to :json

  before_filter :require_client_id, :only => [:create, :update]

  def create
    unless %w(client_id end_date start_date).all? { |k| params.has_key?(k) }
      render :nothing => true, :status => :bad_request and return
    end

    fw = Fieldwork.from_psc(params, psc, current_staff_id, current_username).tap(&:save!)

    respond_to do |wants|
      wants.json do
        headers['Location'] = api_fieldwork_path(fw.fieldwork_id)
        render :json => fw
      end
    end
  end

  def update
    fw = Fieldwork.for(params['id'], current_staff_id)

    begin
      m = fw.merges.create!(:proposed_data => request.body.read,
                            :staff_id => current_staff_id,
                            :client_id => params[:client_id])
    ensure
      request.body.rewind
    end

    NcsNavigator::Core::Field::MergeWorker.perform_async(m.id)
    headers['Location'] = api_merge_path(m.id)
    render :json => { 'ok' => true }, :status => :accepted
  end

  def show
    fw = Fieldwork.find_by_fieldwork_id(params['id'])

    respond_with fw
  end

  def require_client_id
    if params[:client_id].blank?
      render :nothing => true, :status => :bad_request
    end
  end
end
