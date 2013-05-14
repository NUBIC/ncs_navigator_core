# -*- coding: utf-8 -*-

class Api::FieldworkController < ApiController
  def create
    unless %w(end_date start_date).all? { |k| params.has_key?(k) }
      render :nothing => true, :status => :bad_request and return
    end

    fw = Fieldwork.new(:client_id => client_id,
                       :end_date => params[:end_date],
                       :start_date => params[:start_date])

    fw.generated_for = current_username
    fw.staff_id = current_staff_id

    fw.populate_from_psc(psc)
    fw.save!

    respond_with fw, :location => api_fieldwork_path(fw.fieldwork_id)
  end

  def update
    fw = Fieldwork.for(params['id'], current_staff_id)

    begin
      m = fw.merges.create!(:proposed_data => request.body.read,
                            :client_id => client_id,
                            :staff_id => current_staff_id,
                            :username => current_username)
    ensure
      request.body.rewind
    end

    NcsNavigator::Core::Field::MergeWorker.perform_async(m.id)

    respond_with m, :location => api_merge_path(m.id)
  end

  def show
    fw = Fieldwork.find_by_fieldwork_id(params['id'])

    respond_with fw
  end
end
