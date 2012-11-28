require 'celluloid'

log_writer_name = NcsNavigator::Core::Field::LogDevice.file_writer_name
NcsNavigator::Core::Field::LogDevice.file_writer.supervise_as log_writer_name

at_exit do
  Celluloid::Actor[log_writer_name].close
end
