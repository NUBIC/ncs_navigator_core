# If this is a child process, establish a new Redis connection.
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      Rails.application.establish_redis_connection
      Rails.application.sidekiq_configure_client
    end
  end
end
