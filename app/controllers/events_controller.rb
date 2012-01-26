class EventsController < ApplicationController

  # GET /events
  # GET /events.json
  def index
    params[:page] ||= 1

    @q = Event.search(params[:q])
    result = @q.result(:distinct => true)
    @events = result.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.haml
      format.json { render :json => result.all }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        path = events_path
        if @event.participant
          path = @event.participant.person ? person_path(@event.participant.person) : participant_path(@event.participant)
        end

        format.html { redirect_to(path, :notice => 'Event was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

end