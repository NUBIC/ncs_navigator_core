require 'celluloid'

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    log_writer_name = NcsNavigator::Core::Field::LogDevice.file_writer_name
    NcsNavigator::Core::Field::LogDevice.file_writer.supervise_as log_writer_name

    at_exit do
      Celluloid::Actor[log_writer_name].close
    end
  end
else
  log_writer_name = NcsNavigator::Core::Field::LogDevice.file_writer_name
  NcsNavigator::Core::Field::LogDevice.file_writer.supervise_as log_writer_name

  at_exit do
    Celluloid::Actor[log_writer_name].close
  end
end
