class OperationalDataExtractor
    
  class << self
    def process(response_set)
      extractor_for(response_set).extract_data(response_set)
    end
    
    
    def extractor_for(response_set)
      extractor = EXTRACTORS.find { |instrument, handler| instrument =~ response_set.survey.title }
      extractor ? extractor[1] : PregnancyScreenerOperationalDataExtractor
    end
    
    EXTRACTORS = [
      [/_PregScreen_/, PregnancyScreenerOperationalDataExtractor],
      [/_PPGFollUp_/,  PpgFollowUpOperationalDataExtractor],
      [/_PrePreg_/,    PrePregnancyOperationalDataExtractor],
    ]
    
    def response_value(response)
      case response.answer.response_class
      when "string"
        response.string_value
      when "integer"
        response.integer_value
      when "date", "datetime", "time"
        response.datetime_value.strftime('%Y-%m-%d')
      when "text"
        response.text_value
      when "answer"
        response.answer.reference_identifier.gsub("neg_", "-").to_i
      end
    end
  end
  
end