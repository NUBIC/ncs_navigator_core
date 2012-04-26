# -*- coding: utf-8 -*-

class OperationalDataExtractor
  EXTRACTORS = [
    [/_PregScreen_/,    PregnancyScreenerOperationalDataExtractor],
    [/_PPGFollUp_/,     PpgFollowUpOperationalDataExtractor],
    [/_PrePreg_/,       PrePregnancyOperationalDataExtractor],
    [/_PregVisit/,      PregnancyVisitOperationalDataExtractor],
    [/_LIPregNotPreg/,  LowIntensityPregnancyVisitOperationalDataExtractor],
    [/_Birth/,          BirthOperationalDataExtractor],
  ]

  class << self
    def process(response_set)
      extractor_for(response_set).extract_data(response_set)
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

    # PREG_SCREEN_HI_2.ORIG_DUE_DATE
    # PREG_VISIT_LI_2.DUE_DATE
    # PPG_CATI.PPG_DUE_DATE_1
    #
    # PREG_SCREEN_HI_2.DATE_PERIOD
    # PREG_VISIT_LI_2.DATE_PERIOD
    # PPG_CATI.DATE_PERIOD
    # CALCULATE DUE DATE FROM THE FIRST DATE OF LAST MENSTRUAL PERIOD AND SET ORIG_DUE_DATE = DATE_PERIOD + 280 DAYS
    #
    # PREG_SCREEN_HI_2.WEEKS_PREG
    # PPG_CATI.WEEKS_PREG
    # CALCULATE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – WEEKS_PREG * 7
    #
    # PREG_SCREEN_HI_2.MONTH_PREG
    # PPG_CATI.MONTH_PREG
    # CALCULATE DUE DATE AS FROM NUMBER OF MONTHS PREGNANT WHERE ORIG_DUE_DATE =TODAY’S DATE + 280 DAYS – MONTH_PREG * 30 - 15
    #
    # PREG_SCREEN_HI_2.TRIMESTER
    # PPG_CATI.TRIMESTER
    # # 1ST TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 46 DAYS).
    # # 2ND TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS).
    # # 3RD TRIMESTER:      ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 235 DAYS).
    # # DON’T KNOW/REFUSED: ORIG_DUE_DATE = TODAY’S DATE + (280 DAYS – 140 DAYS)
    def determine_due_date(key, response)

      return nil unless should_calculate_due_date?(key, response)

      value = case response.answer.response_class
              when "integer"
                response.integer_value
              when "date", "datetime", "time"
                response.datetime_value
              when "answer"
                response.answer.reference_identifier.gsub("neg_", "-").to_i
              end

      due_date =  case key
                  when "ORIG_DUE_DATE", "DUE_DATE", "PPG_DUE_DATE_1"
                    value
                  when "DATE_PERIOD"
                    value + 280.days
                  when "WEEKS_PREG"
                    (Date.today + 280.days) - ((value * 7).days)
                  when "MONTH_PREG"
                    (Date.today + 280.days) - ((value * 30) - 15)
                  when "TRIMESTER"
                    case value
                    when 1
                      (Date.today + 280.days) - (46.days)
                    when 2
                      (Date.today + 280.days) - (140.days)
                    when 3
                      (Date.today + 280.days) - (235.days)
                    else
                      (Date.today + 280.days) - (140.days)
                    end
                  else
                    (Date.today + 280.days) - (140.days)
                  end

      due_date.strftime('%Y-%m-%d') unless due_date.blank?
    end

    def should_calculate_due_date?(key, response)
      answer_class = response.answer.response_class
      case key
      when "ORIG_DUE_DATE", "DUE_DATE", "PPG_DUE_DATE_1", "DATE_PERIOD"
        answer_class == "date"
      when "WEEKS_PREG", "MONTH_PREG"
        answer_class == "integer"
      when "TRIMESTER"
        answer_class == "answer"
      else
        false
      end

    end

    def set_participant_type(participant, ppg_code)
      p_type_code = nil
      case ppg_code
      when 1
        p_type_code = 3
      when 2
        p_type_code = 2
      when 3,4
        p_type_code = 1
      end
      if p_type_code
        participant.p_type = NcsCode.for_attribute_name_and_local_code(:p_type_code, p_type_code)
      end
    end

    def primary_rank
      @primary_rank ||= NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 1)
    end

  end

end