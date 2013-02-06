begin
  EventTypeOrder.persist_if_different
rescue ActiveRecord::RecordNotUnique
  Rails.logger.warn("Worker #{$$} generated a duplicate record while persisting event type order; some other worker is probably doing the same thing.")
end
