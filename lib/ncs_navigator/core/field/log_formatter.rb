module NcsNavigator::Core::Field
  ##
  # Formats log messages for Field support code.
  #
  # Messages are formatted like this:
  #
  #   2000-01-01T12:00:00Z PID Fieldwork 172 (0xobject_id) UNKNOWN -- : message
  #
  # We use object IDs and database IDs because this log formatter may be used
  # with unpersisted models.
  class LogFormatter
    ##
    # Object IDs are Fixnums, which may be as large as the machine's word size.
    # We use this fact to format our log messages.
    #
    # The nibble -> byte conversion is done because we write object IDs in
    # base-16.
    MAXLEN = 0.size * 2

    ##
    # The log message format.
    FORMAT = "%s %6d %16s (0x%0#{MAXLEN}x) %07s -- : %s\n"

    ##
    # @param [ActiveRecord::Base] model the model that owns the logger
    def initialize(model)
      @model = model
      
      @model_name = @model.class.name
      @model_id = @model.id.inspect
      @model_object_id = @model.object_id
    end

    def call(severity, time, progname, msg)
      FORMAT % [
        format_datetime(time),
        $$,
        @model_name + " " + @model_id,
        @model_object_id,
        severity,
        msg
      ]
    end

    def format_datetime(time)
      time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end
  end
end
