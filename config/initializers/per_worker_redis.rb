# If this is a child process, establish a new Redis connection.
if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Rails.application.establish_redis_connection if forked
  end
end
