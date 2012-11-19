module Field
  class EventTemplateCollection
    include Enumerable

    def each
      yield
    end

    def as_json(options = nil)
      { 'event_templates' => [] }
    end
  end
end
