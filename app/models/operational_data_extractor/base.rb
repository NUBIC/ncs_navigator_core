# -*- coding: utf-8 -*-


module OperationalDataExtractor
  class Base

    attr_accessor :response_set

    MISSING_IN_ERROR = -4

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

    def due_date_response(response_set, date_question, prefix)
      if dt = date_string(response_set, date_question, prefix)
        begin
          determine_due_date(
            "#{date_question}_DD",
            response_for(response_set, "#{prefix}.#{date_question}_DD"),
            Date.parse(dt)
          )
        rescue
          #NOOP - unparseable date
        end
      end
    end

    def date_string(response_set, str, prefix)
      dt = []
      ['YY', 'MM', 'DD'].each do |date_part|
        if r = response_for(response_set, "#{prefix}.#{str}_#{date_part}")
          val = response_value(r)
          dt << val if val.to_i > 0
        end
      end
      dt.join("-")
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

    def address_other_type
      @address_other_type ||= NcsCode.for_list_name_and_local_code('ADDRESS_CATEGORY_CL1', -5)
    end

    def personal_email_type
      @personal_email_type ||= NcsCode.for_list_name_and_local_code('EMAIL_TYPE_CL1', 1)
    end

    def home_phone_type
      @home_phone_type ||= NcsCode.for_list_name_and_local_code('PHONE_TYPE_CL1', 1)
    end

    def other_institute_type
      @other_institution_type ||= NcsCode.for_list_name_and_local_code('ORGANIZATION_TYPE_CL1', -5)
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

    def update_instrument_mode
      if r = data_export_identifier_indexed_responses["prepopulated_mode_of_contact"]
        v = nil
        case r.answer.reference_identifier
        when "capi"
          v = Instrument.capi
        when "cati"
          v = Instrument.cati
        when "papi"
          v = Instrument.papi
        end
        response_set.instrument.update_attribute(:instrument_mode_code, v) unless v.blank?
      end
    end

    def person
      response_set.person
    end

    def participant
      response_set.participant
    end

    # For surveys that update the child - the participant on the response_set
    # should be the child participant and thus the person being updated is the
    # child participant.person
    def child
      participant.person
    end

    def get_address(response_set, person, address_type, address_rank)
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
      criteria[:phone_rank_code] = phone_rank.local_code
      criteria[:phone_type_code] = phone_type.local_code if phone_type
      phone = Telephone.where(criteria).last
      if phone.nil?
        phone = Telephone.new(:person => person, :psu => person.psu,
                              :response_set => response_set,
                              :phone_rank => phone_rank)
        phone.phone_type = phone_type if phone_type
      end
      phone
    end

    def get_email(response_set, person, email_type)
      email = Email.where(:response_set_id => response_set.id, :email_type_code => email_type.local_code).first
      if email.nil?
        email = Email.new(:person => person, :psu => person.psu,
                          :response_set => response_set,
                          :email_type => email_type,
                          :email_rank => primary_rank)
      end
      email
    end

    def get_birth_address(response_set, person, address_type, address_rank)
      criteria = Hash.new
      criteria[:response_set_id] = response_set.id
      criteria[:address_type_code] = address_type.local_code
      criteria[:address_rank_code] = address_rank.local_code
      criteria[:address_type_other] = "Birth"
      birth_address = Address.where(criteria).first
      if birth_address.nil?
        birth_address = Address.new(:person => person, :dwelling_unit => DwellingUnit.new,
                                    :psu => person.psu, :response_set => response_set,
                                    :address_type => address_type, :address_rank => address_rank,
                                    :address_type_other => "Birth")
      end
      birth_address
    end

    def get_institution(response_set, institute_type)
      institution = Institution.where(:response_set_id => response_set.id, :institute_type_code => institute_type.local_code).first
      if institution.nil?
        institution = Institution.new( :psu => person.psu, :institute_type_code => institute_type.local_code, :response_set => response_set)
      end
      institution
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

    def process_person(map)
      set_value_during_process(map, person)
    end

    def set_value_during_process(map, owner)
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          set_value(owner, attribute, response_value(r))
        end
      end
    end

    private :set_value_during_process

    def process_participant(map)
      set_value_during_process(map, participant) if participant
    end

    def process_ppg_details(owner, map, prefix)
      ppg_detail = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            ppg_detail ||= get_ppg_detail(response_set, owner)
            ppg_detail.send("#{attribute}=", ppg_detail_value(prefix, key, value))
          end
        end
      end
      ppg_detail
    end

    def process_ppg_status(map)
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            participant.ppg_details.first.update_due_date(value, get_due_date_attribute(key))
          end
        end
      end
    end

    def process_child(map)
      set_value_during_process(map, child) if child
      child
    end

    def process_child_dob(map)
      set_value_during_process(map, child) if child
    end

    def process_father(map)
      father = nil
      relationship = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            if attribute == "full_name"
              full_name = value.split
              if full_name.size >= 2
                last_name = full_name.last
                first_name = full_name[0, (full_name.size - 1) ].join(" ")
                father ||= Person.where(:response_set_id => response_set.id,
                                        :first_name => first_name,
                                        :last_name => last_name).first
              else
                father ||= Person.where(:response_set_id => response_set.id,
                                        :first_name => value.to_s).first
              end
            else
              father ||= Person.where(:response_set_id => response_set.id,
                                      attribute => value.to_s).first
            end

            if father.nil?
              father = Person.new(:psu => person.psu, :response_set => response_set)
              # TODO: determine the default relationship for Father when creating father esp. when child has not been born
              # 7 Partner/Significant Other
              relationship = ParticipantPersonLink.new(:person => father,
                :participant => participant, :relationship_code => 7)
            end

            set_value(father, attribute, value)
          end
        end
      end
      [father, relationship]
    end

    def process_contact(map)
      contact = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            contact ||= Person.where(:response_set_id => response_set.id,
                                      attribute => value.to_s).first
            if contact.nil?
              contact = Person.new(:psu => person.psu, :response_set => response_set)
            end
            set_value(contact, attribute, value)
          end
        end
      end
      contact
    end

    def process_contact_relationship(owner, map)
      relationship = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            relationship ||= ParticipantPersonLink.where(:response_set_id => response_set.id,
                                                                  attribute => value.to_s).first
            if relationship.nil?
              relationship = ParticipantPersonLink.new(:person => owner, :participant => participant,
                                                               :psu => person.psu, :response_set => response_set)
            end
            set_value(relationship, attribute, contact_to_person_relationship(value))
          end
        end
      end
      relationship
    end

    def process_birth_institution_and_address(birth_address_map, institution_map, institute_type = other_institute_type, address_type = address_other_type, address_rank = primary_rank)
      birth_address = get_birth_address(response_set, participant.person, address_type,  address_rank)
      institution = process_institution(institution_map, response_set, institute_type)

      birth_address_map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            set_value(birth_address, attribute, value)
          end
        end
      end
      [birth_address, institution]
    end

    def process_address(owner, map, address_type = address_other_tyoe, address_rank = primary_rank)
      address = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            address ||= get_address(response_set, owner, address_type, address_rank)
            set_value(address, attribute, value)
          end
        end
      end
      address
    end

    def finalize_addresses(*addresses)
      if any_address_changes?(addresses)
        changed_addresses = which_addresses_changed(addresses).flatten
        changed_addresses.each do |change_addrs|
          person.addresses.each { |a| a.demote_primary_rank_to_secondary(change_addrs.address_type_code) }
        end
        addresses.flatten.each { |a| a.save! unless a.to_s.blank? }
      end
    end

    def any_address_changes?(addresses)
      addresses.detect{ |a| !a.to_s.blank? }
    end

    def which_addresses_changed(addresses)
      addresses.find_all{ |a| !a.to_s.blank? }
    end

    def process_telephone(owner, map, phone_type = home_phone_type, phone_rank = primary_rank)
      phone = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            phone ||= get_telephone(response_set, owner, phone_type, phone_rank)
            set_value(phone, attribute, value)
          end
        end
      end
      phone
    end

    def finalize_telephones(*telephones)
      if any_telephone_changes?(telephones)
        changed_phones = which_telephones_changed(telephones).flatten
        changed_phones.each do |phone|
          person.telephones.each { |t| t.demote_primary_rank_to_secondary(phone.phone_type_code) }
        end
        telephones.flatten.each { |t| t.save! unless t.try(:phone_nbr).blank? }
      end
    end

    def any_telephone_changes?(telephones)
      telephones.detect{ |t| !t.try(:phone_nbr).blank? }
    end

    def which_telephones_changed(telephones)
      telephones.find_all{ |t| !t.try(:phone_nbr).blank? }
    end

    def process_email(map, email_type = personal_email_type)
      email = nil
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            email ||= get_email(response_set, person, email_type)
            set_value(email, attribute, value)
          end
        end
      end
      email
    end

    def process_institution(map, response_set, type = other_institute_type)
      institution = get_institution(response_set, type)
      map.each do |key, attribute|
        if r = data_export_identifier_indexed_responses[key]
          value = response_value(r)
          unless value.blank?
            set_value(institution, attribute, value)
          end
        end
      end
      institution
    end

    def finalize_institution(institute)
      ActiveRecord::Base.transaction do
        unless institute.blank?
          ipl = InstitutionPersonLink.new
          ipl.person = participant.person
          ipl.institution = institute
          ipl.save!
          institute.save!
        end
      end
    end

    def finalize_institution_with_birth_address(birth_address, institute)
      ActiveRecord::Base.transaction do
         finalize_institution(institute)
         birth_address.save! unless birth_address.blank?
         institute.addresses << birth_address unless birth_address.blank?
       end
    end

    def institution_empty?(institution)
      institution_contents = []
      institution_components = [:institute_name, :institute_type]
      institution_components.each { |ic| institution_contents << institution.send(ic) }
      institution_contents.all? { |ic| ic == MISSING_IN_ERROR || ic.nil? }
    end

    def finalize_ppg_status_history(ppg_status_history)
      if ppg_status_history && !ppg_status_history.ppg_status_code.blank?
        set_participant_type(participant, ppg_status_history.ppg_status_code)
        ppg_status_history.save!
      end
    end

    def finalize_email(email)
      unless email.try(:email).blank?
        person.emails.each { |e| e.demote_primary_rank_to_secondary(email.email_type_code) }
        email.save!
      end
    end

    def finalize_contact(contact, relationship, address, telephone, alt_phone = nil)
      if contact && relationship &&
        !contact.to_s.blank? && !relationship.relationship_code.blank?

        address.save! unless address.to_s.blank?
        telephone.save! unless telephone.try(:phone_nbr).blank?
        alt_phone.save! unless alt_phone.try(:phone_nbr).blank?

        contact.save!
        relationship.person_id = contact.id
        relationship.participant_id = participant.id
        relationship.save!
      end
    end

    def finalize_father(father, relationship, address, phone)
      if father
        if address && !address.to_s.blank?
          address.person = father
          address.save!
        end
        if phone && !phone.phone_nbr.blank?
          phone.person = father
          phone.save!
        end
        father.save!
        relationship.person_id = father.id
        relationship.participant_id = participant.id
        relationship.save!
      end
    end

    def process_person_race(person_race_map)
      person_race_map.each do |key, attribute|
        collect_race_responses(key).each do |r|
          person_race = get_person_race
          if value = response_value(r)
            if key =~ /NEW/
              process_new_type_race(person_race, attribute, r)
            else
              process_standard_race(person_race, attribute, value)
            end
          end
        end
      end
    end

    ##
    # Similar to data_export_identifier_indexed_responses, but since
    # Race selection is a pick any, there can be more than one
    # race response for any data_export_identifier
    # @param[String]
    # @return[Array<Response>]
    def collect_race_responses(data_export_identifier)
      result = Array.new
      sorted_responses.each do |r|
        dei = r.question.data_export_identifier
        result << r if known_keys.include?(dei) && dei == data_export_identifier
      end
      result
    end

    ##
    # Creates a PersonRace record. If the response text and value
    # does not match something in the RACE_CL1 code list, then we
    # create an /other/ response for the PersonRace.
    # (i.e. race_code = -5 - other and race_other = display_text)
    def process_new_type_race(person_race, attribute, response)
      value = response_value(response)

      if standard_person_race_codes.include?(value)
        set_value(person_race, attribute, value)
      elsif response.answer.response_class == "answer"
        person_race.race_code = NcsCode::OTHER
        person_race.race_other = response.answer.text
      else
        person_race.race_other = value
      end
      person_race.save!
    end

    def standard_person_race_codes
      @race_cl1_codes ||= NcsCode.ncs_code_lookup(:race_code).map(&:last)
    end

    ##
    # Creates a PersonRace record using the RACE_CL1 code list
    def process_standard_race(person_race, attribute, value)
      set_value(person_race, attribute, value)
      person_race.save!
    end

    def get_person_race
      person_race = person.races.where(:race_code => NcsCode::OTHER, :race_other => nil).first
      person_race = person.races.build if person_race.nil?
      person_race
    end

  end
end
