module Field
  ##
  # An event template represents an event and its corresponding instruments.
  # This information is used (in JSON-serialized form) by Field to gather data
  # for creating new {Event} and {Instrument} records.
  #
  # This model derives some additional data for event templates (i.e. event and
  # instrument type codes).  It has no JSON serialization code; see
  # {Field::Serialization#event_templates_as_json} (which uses this model) for
  # details on the serialization process.
  #
  # This model is meant for use with the models in {Psc::ImpliedEntities}.
  #
  # NOTE: This model DOES NOT ensure that the event and instruments actually
  # belong together.  The onus of association is on users of this model.
  class EventTemplate < Struct.new(:event, :instruments)
    def initialize(*)
      super

      self.instruments ||= []
    end
  end
end
