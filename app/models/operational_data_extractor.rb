class OperationalDataExtractor
  EXTRACTORS = [
    [/_PregScreen_/, PregnancyScreenerOperationalDataExtractor],
    [/_PPGFollUp_/,  PpgFollowUpOperationalDataExtractor],
    [/_PrePreg_/,    PrePregnancyOperationalDataExtractor],
    [/_PregVisit/,   PregnancyVisitOperationalDataExtractor],
  ]  
  
  class << self
    def process(response_set)
      if !response_set.processed_for_operational_data_extraction
        success = extractor_for(response_set).extract_data(response_set)
        response_set.update_attribute(:processed_for_operational_data_extraction, true) if success
      end
    end
    
    
    def extractor_for(response_set)
      extractor = EXTRACTORS.find { |instrument, handler| instrument =~ response_set.survey.title }
      extractor ? extractor[1] : PregnancyScreenerOperationalDataExtractor
    end
    
    def response_value(response)
      case response.answer.response_class
      when "string"
        response.string_value
      when "integer"
        response.integer_value
      when "date", "datetime", "time"
        response.datetime_value.strftime('%Y-%m-%d') unless response.datetime_value.blank?
      when "text"
        response.text_value
      when "answer"
        response.answer.reference_identifier.gsub("neg_", "-").to_i
      end
    end
  
    ##
    # Convert Contact Survey code to Person/Participant Relationship code
    # 
    # CONTACT_RELATIONSHIP_CL2
    #   1 Mother/Father
    #   2 Brother/Sister
    #   3 Aunt/Uncle
    #   4 Grandparent
    #   5 Neighbor
    #   6 Friend
    #   -5  Other
    # PERSON_PARTCPNT_RELTNSHP_CL1
    #   1 Participant/Self
    #   2 Biological Mother
    #   3 Non-Biological Mother
    #   4 Biological Father
    #   5 Non-Biological Father
    #   6 Spouse
    #   7 Partner/Significant Other
    #   8 Child
    #   9 Sibling
    #   10  Grandparent
    #   11  Other relative
    #   12  Friend
    #   13  Neighbor
    #   14  Co-Worker
    #   15  Care-giver
    #   16  Teacher
    #   17  Primary health care provider
    #   18  Other health care provider
    #   -5  Other
    def contact_to_person_relationship(value)
      # TODO: FIXME: Determine how to handle Mother/Father value
      case value
      when 1  # Mother/Father
        2       # Default to Biological Mother for now 
      when 2  # Brother/Sister
        9       # Sibling
      when 3  # Aunt/Uncle
        11      # Other relative
      when 4  # Grandparent
        10      # Grandparent
      when 5  # Neighbor
        13      # Neighbor
      when 6  # Friend
        12      # Friend
      when -5, -4
        value   # Other, Missing in Error
      else 
        nil     # No mapping value
      end
    end
  
  end
  
end