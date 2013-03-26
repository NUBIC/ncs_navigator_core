class Api::EventsController < ApiController
  KNOWN_FILTERS = %w(
    data_collectors
    scheduled_date
    types
  )

  before_filter :require_filter, :only => :index

  def index
  end

  def require_filter
    if KNOWN_FILTERS.none? { |k| params.has_key?(k) }
      render :nothing => true, :status => :bad_request
    end
  end
end
