require 'celluloid'

module NcsNavigator::Core::Field
  ##
  # A class intended to be used as a log device for Ruby's standard Logger.
  # The logger using this device should use a {LogFormatter} instance as its
  # formatter.
  #
  # This class writes log messages to two locations:
  #
  # 1. The provided IO.
  # 2. A file, which by default is #{Rails.root}/log/field_#{Rails.env}.log.
  #
  # In order to:
  #
  # 1. insulate the log device from additional complexity caused by writing to
  #    the filesystem
  # 2. control the number of open log file descriptors
  #
  # this device does not directly write to the log file.  Instead, it passes
  # log messages to the :field_log_writer actor, which writes those messages on
  # its own schedule.  In some exceptional situations (e.g. insufficient disk
  # space) this means that we may lose log messages in the log file, but such
  # an issue will not directly crash the log device.
  class LogDevice
    attr_reader :io

    def self.file_writer_name
      :field_log_writer
    end

    ##
    # Returns the class of the actor used to stream log messages to files.
    def self.file_writer
      FileWriter
    end

    def initialize(io)
      @io = io
    end

    ##
    # Attempts to rewind the provided IO.  Does not rewind the file writer
    # stream.
    def rewind
      io.rewind rescue nil
    end

    ##
    # Issues #read to the provided IO.
    def read
      io.read
    end

    ##
    # Closes the provided IO.  Part of the Logger::LogDevice interface.
    #
    # This does not close the file writer.
    def close
      io.close
    end

    ##
    # Writes a message to the IO and sends a write message to the file writer.
    # Part of the Logger::LogDevice interface.
    def write(message)
      io.write(message)
      Celluloid::Actor[self.class.file_writer_name].async.write(message)
    end

    ##
    # @private
    class FileWriter
      include Celluloid

      def initialize
        @file = File.open(log_file, 'a')
        @file.sync = true
      end

      def close
        @file.close
      end

      def write(message)
        @file.write(message)
      end

      def log_file
        Rails.root.join("log/field_#{Rails.env}.log")
      end
    end
  end
end
