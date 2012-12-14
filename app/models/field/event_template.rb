module Field
  ##
  # An event template represents an event and its corresponding instruments.
  # This information is used (in JSON-serialized form) by Field to gather data
  # for creating new {Event} and {Instrument} records.
  #
  # Along with instruments, the event template may provide prepopulated
  # responses that should be instantiated along with instruments.  These are
  # present in {#response_templates} and are represented as {ResponseTemplate}
  # objects.
  #
  # This model derives some additional data for event templates (i.e. event and
  # instrument type codes).  It has no JSON serialization code; see
  # {Field::Serialization#event_templates_as_json} (which uses this model) for
  # details on the serialization process.
  #
  # This model is meant for use with the models in {Psc::ImpliedEntities}.
  #
  # NOTE: This model DOES NOT ensure that the event, instruments, and response
  # templates actually belong together.  The onus of association is on users of
  # this model.
  class EventTemplate < Struct.new(:event, :instruments, :response_templates)
    def initialize(*)
      super

      self.instruments ||= []
      self.response_templates ||= []
    end
  end
end
