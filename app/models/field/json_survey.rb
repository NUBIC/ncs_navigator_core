module Field
  ##
  # Eliminates the need to reparse {Survey}s as JSON strings when including
  # said strings in larger JSON structures.
  class JsonSurvey
    def initialize(str)
      @str = str
    end

    def as_json(*)
      self
    end

    def to_json(*)
      @str
    end

    # ActiveModel::Serializers compatibility.
    alias_method :encode_json, :to_json
  end
end
