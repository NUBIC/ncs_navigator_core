# -*- coding: utf-8 -*-


module OperationalDataExtractor
  class Base

    attr_accessor :response_set

    class << self
      def process(response_set)
        extractor_for(response_set).extract_data
      end

      def extractor_for(response_set)
        extractor = EXTRACTORS.find { |instrument, handler| instrument =~ response_set.survey.title }
        extractor ? extractor[1].new(response_set) : OperationalDataExtractor::PregnancyScreener.new(response_set)
      end
    end

    def initialize(response_set)
      @response_set = response_set
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
    def determine_due_date(key, response, value = nil)
      return nil unless should_calculate_due_date?(key, response)

      value = determine_value_from_response(response) if value.nil?

      due_date =  case key
                  when "ORIG_DUE_DATE", "DUE_DATE", "PPG_DUE_DATE_1"
                    value
                  when "ORIG_DUE_DATE_MM", "ORIG_DUE_DATE_DD", "ORIG_DUE_DATE_YY"
                    value
                  when "DUE_DATE_MM", "DUE_DATE_DD", "DUE_DATE_YY"
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
      when "ORIG_DUE_DATE", "PPG_DUE_DATE_1"
        answer_class == "date"
      when "DUE_DATE"
        answer_class == "date" || answer_class == "string"
      when "DATE_PERIOD"
        answer_class == "date" || answer_class == "string"
      when "WEEKS_PREG", "MONTH_PREG"
        answer_class == "integer"
      when "TRIMESTER"
        answer_class == "answer"
      when "ORIG_DUE_DATE_MM", "ORIG_DUE_DATE_DD", "ORIG_DUE_DATE_YY"
        answer_class == "string"
      when "DUE_DATE_MM", "DUE_DATE_DD", "DUE_DATE_YY"
        answer_class == "string"
      when "DATE_PERIOD_MM", "DATE_PERIOD_DD", "DATE_PERIOD_YY"
        answer_class == "string"
      else
        false
      end

    end

    def determine_value_from_response(response)
      value = case response.answer.response_class
              when "integer"
                response.integer_value
              when "date", "datetime", "time"
                response.datetime_value
              when "answer"
                response.answer.reference_identifier.gsub("neg_", "-").to_i
              end
      value
    end

    ##
    # Set the Participant.participant_type_code based on the ppg_status
    # PPG STATUS
    # 1 PPG Group 1: Pregnant and Eligible
    # 2 PPG Group 2: High Probability – Trying to Conceive
    # 3 PPG Group 3: High Probability – Recent Pregnancy Loss
    # 4 PPG Group 4: Other Probability – Not Pregnancy and not Trying
    #
    # PARTICIPANT_TYPE
    # 1 Age-eligible woman, ineligible for pre-pregnancy visit - being followed
    # 2 High-Trier - eligible for Pre-Pregnancy Visit
    # 3 Pregnant eligible woman
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

    def secondary_rank
      @secondary_rank ||= NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 2)
    end

    def duplicate_rank
      @duplicate_rank ||= NcsCode.for_list_name_and_local_code('COMMUNICATION_RANK_CL1', 4)
    end

    def set_value(obj, attribute, value)
      if value.blank?
        log_error(obj, "#{attribute} not set because value is blank.")
      elsif attribute.include?('_code')
        obj.send("#{attribute}=", value)
      else
        validate_and_set(obj, attribute, value)
      end
    end

    ##
    # Do not set if not an NCS Code attribute and value is negative
    # or if the value is not valid
    def validate_and_set(obj, attribute, value)
      if value.to_i >= 0
        obj.send("#{attribute}=", value)
        validators = obj.class.validators_on(attribute)
        if !validators.empty?
          validators.each { |v| v.validate obj }

          unless obj.errors.full_messages.blank?
            obj.send("#{attribute}=", nil)
            log_error(obj, "#{attribute} not set because #{obj.errors.full_messages.to_sentence}.")
            obj.errors.clear
          end
        end
      else
        log_error(obj, "#{attribute} not set because #{value} is negative.")
      end
    end

    def log_error(obj, msg)
      path = error_log_path
      File.open(path, 'w') { |f| f.write("[#{Time.now.to_s(:db)}] OPERATIONAL DATA EXTRACTION ERROR LOG\n\n") } unless File.exists?(path)
      File.open(path, 'a') { |f| f.write("[#{Time.now.to_s(:db)}] [#{obj.class}] [#{obj.id}] #{msg}") }
    end

    def error_log_path
      dir = "#{Rails.root}/log/operational_data_extractor"
      FileUtils.makedirs(dir) unless File.exists?(dir)
      log_path = "#{dir}/#{Date.today.strftime('%Y%m%d')}_data_extraction_errors.log"
      log_path
    end

    def known_keys
      @known_keys ||= get_keys_from_maps
    end

    def get_keys_from_maps
      maps.collect { |m| m.keys }.flatten
    end

    def maps
      # To be implemented by subclass
      []
    end

    def data_export_identifier_indexed_responses
      @indexed_responses ||= collect_data_export_identifier_indexed_responses
    end

    def collect_data_export_identifier_indexed_responses
      result = Hash.new
      sorted_responses.each do |r|
        dei = r.question.data_export_identifier
        result[dei] = r if known_keys.include?(dei)
      end
      result
    end

    def sorted_responses
      response_set.responses.sort_by { |r| r.created_at }
    end

    def get_address(response_set, person, address_type, address_rank = primary_rank)
      criteria = Hash.new
      criteria[:response_set_id] = response_set.id
      criteria[:address_type_code] = address_type.local_code
      criteria[:address_rank_code] = address_rank.local_code
      address = Address.where(criteria).first
      if address.nil?
        address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new,
                              :psu => person.psu, :response_set => response_set,
                              :address_type => address_type, :address_rank => address_rank)
      end
      address
    end

    def get_telephone(response_set, person, phone_type = nil, phone_rank = primary_rank)
      criteria = Hash.new
      criteria[:response_set_id] = response_set.id
      criteria[:phone_type_code] = phone_type.local_code if phone_type
      criteria[:phone_rank_code] = phone_rank.local_code if phone_rank
      phone = Telephone.where(criteria).last
      if phone.nil?
        phone = Telephone.new(:person => person, :psu => person.psu,
                              :response_set => response_set,
                              :phone_rank => phone_rank)
        phone.phone_type = phone_type if phone_type
      end
      phone
    end

    def get_secondary_telephone(response_set, person, phone_type = nil)
      criteria = Hash.new
      criteria[:response_set_id] = response_set.id
      criteria[:phone_rank_code] = secondary_rank.local_code
      criteria[:phone_type_code] = phone_type.local_code if phone_type
      phone = Telephone.where(criteria).last
      if phone.nil?
        phone = Telephone.new(:person => person, :psu => person.psu,
                              :response_set => response_set,
                              :phone_rank => secondary_rank)
        phone.phone_type = phone_type if phone_type
      end
      phone
    end


    def get_email(response_set, person)
      email = Email.where(:response_set_id => response_set.id).first
      if email.nil?
        email = Email.new(:person => person, :psu => person.psu,
                          :response_set => response_set,
                          :email_rank => primary_rank)
      end
      email
    end

    def get_ppg_detail(response_set, participant)
      ppg_detail = PpgDetail.where(:response_set_id => response_set.id).first
      if ppg_detail.nil?
        ppg_detail = PpgDetail.new(:participant => participant, :psu => participant.psu,
                                   :response_set => response_set)
      end
      ppg_detail
    end

    def ppg_detail_value(prefix, key, value)
      result = value
      case key
      when "#{prefix}.PREGNANT"
        result = value
      when "#{prefix}.TRYING"
        case value
        when 1 # when Yes to Trying - set ppg_first_code to 2 - Trying
          result = 2
        when 2 # when No to Trying - set ppg_first_code to 4 - Not Trying
          result = 4
        else  # Otherwise Recent Loss, Not Trying, Unable match ppg_first_code
          result = value
        end
      when "#{prefix}.HYSTER", "#{prefix}.OVARIES", "#{prefix}.TUBES_TIED", "#{prefix}.MENOPAUSE", "#{prefix}.MED_UNABLE", "#{prefix}.MED_UNABLE_OTH"
        result = 5 if value == 1 # If yes to any set the ppg_first_code to 5 - Unable to become pregnant
      else
        result = value
      end
      result
    end

  end
end
