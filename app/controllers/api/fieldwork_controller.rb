# -*- coding: utf-8 -*-


class Api::FieldworkController < ApplicationController
  respond_to :json

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
      m = fw.merges.create!(:proposed_data => request.body.read)
    ensure
      request.body.rewind
    end

    NcsNavigator::Core::Fieldwork::MergeWorker.perform_async(m.id)
    headers['Location'] = api_merge_path(m.id)
    render :nothing => true, :status => :accepted
  end

  def show
    fw = Fieldwork.find_by_fieldwork_id(params['id'])

    respond_with fw
  end
end
