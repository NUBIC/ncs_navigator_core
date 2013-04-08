# -*- coding: utf-8 -*-

require 'ncs_navigator/core'


module NcsNavigator::Core::Mustache
  ##
  # This is an instrument context object that provides a
  # Mustache object with keys known to NCS instruments.
  class InstrumentContext

    attr_reader :response_set

    def initialize(response_set)
      @response_set = response_set
    end

    def response_for(data_export_identifier)
      raise InvalidStateException, "No response set exists for this Instrument Context" unless @response_set
      Response.includes([:answer, :question, :response_set]).
                where("response_sets.user_id = ? AND questions.data_export_identifier = ?",
                      @response_set.person.id, data_export_identifier).last.to_s
    end

    def interviewer_name
      '[INTERVIEWER NAME]'
    end

    def p_full_name
      full_name = @response_set.person.try(:full_name)
      full_name.blank? ? '[UNKNOWN]' : full_name
    end

    def p_dob
      @response_set.person.try(:person_dob) || "[UNKNOWN]"
    end

    def p_cell_phone
      cell_phone = "[CELL PHONE NUMBER]"
      if person = @response_set.try(:person)
        cell_phone = format_phone_number(person.primary_cell_phone) if person.primary_cell_phone
      end
      cell_phone
    end

    def p_home_phone
      home_phone = "[HOME PHONE NUMBER]"
      if person = @response_set.try(:person)
        home_phone = format_phone_number(person.primary_home_phone) if person.primary_home_phone
      end
      home_phone
    end

    def p_phone_number
      if person = @response_set.try(:person)
        home_phone = p_home_phone
        cell_phone = p_cell_phone

        result = nil
        result = format_phone_number(cell_phone) unless cell_phone == "[CELL PHONE NUMBER]"
        result = format_phone_number(home_phone) unless home_phone == "[HOME PHONE NUMBER]"
        result
      end
    end

    def format_phone_number(nbr)
      nbr = nbr.to_s
      return nbr if nbr.length != 10
      nbr.insert(3, "-").insert(7, "-")
    end

    def p_email_address
      email_address = "[EMAIL ADDRESS]"
      if person = @response_set.try(:person)
        email_address = person.primary_email if person.primary_email
      end
      email_address
    end

    def p_primary_address
      primary_address = "[What is your street address?]"
      if person = @response_set.try(:person)
        primary_address = "Let me confirm your street address. I have it as #{person.primary_address}." if person.primary_address
      end
      primary_address
    end

    def participant_parent_caregiver_name
      result = p_full_name
      if result.blank? || result == '[UNKNOWN]'
        result = "[Participant/Parent/Caregiver Name]"
      end
      result
    end

    #Nataliya's comment - not used anywhere
    def pregnancy_to_confirm
      # TODO: add (Just to confirm) . . . if participant known to be pregnant
      "A"
    end

    #Nataliya's comment = I think this is handled with dependencies in PBSamplingScreen
    def visit_today
      # TODO: the impossible - know the first date of visit with provider
      # {Is your visit today/{Was your visit on {DATE OF VISIT}}
      "Is your visit today"
    end

    ### Dates and times ###

    def last_year
      (Time.now.year - 1).to_s
    end

    def thirty_days_ago
      30.days.ago.strftime("%m/%d/%Y")
    end

    def day_and_date_of_past_interview
      "[DAY AND DATE OF PAST INTERVIEW]"
    end

    def month_of_interview
      "[MONTH OF INTERVIEW]"
    end


    ### Configuration Information ###

    def local_study_affiliate
      NcsNavigator.configuration.core["study_center_name"]
    end

    def toll_free_number
      NcsNavigator.configuration.core["toll_free_number"]
    end

    def local_age_of_minority
      NcsNavigator.configuration.core["local_age_of_minority"]
    end

    def local_age_of_majority
      NcsNavigator.configuration.core["local_age_of_majority"]
    end

    ### Birth Instruments ###

    # BABY_NAME_PREFIX    = "BIRTH_VISIT_BABY_NAME_2"
    # BIRTH_VISIT_PREFIX  = "BIRTH_VISIT_2"
    # BIRTH_VISIT_3_PREFIX = "BIRTH_VISIT_3"
    # BABY_NAME_LI_PREFIX = "BIRTH_VISIT_LI_BABY_NAME"
    # BIRTH_LI_PREFIX     = "BIRTH_VISIT_LI"

    def multiple_release_birth_visit_prefix
      case @response_set.survey.title
      when /_PregVisit1_(.)*2/
        OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_2_INTERVIEW_PREFIX
      when /_PregVisit1_(.)*3/
        OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_3_INTERVIEW_PREFIX
      when /Birth_INT_LI_M3\.1_V2\.0_/
        OperationalDataExtractor::Birth::BIRTH_LI_2_PREFIX
      when /_Birth_INT_LI_/
        OperationalDataExtractor::Birth::BIRTH_LI_PREFIX
      when /_Birth_INT_M3.2_/
        OperationalDataExtractor::Birth::BIRTH_VISIT_4_PREFIX
      else
        if NcsNavigatorCore.mdes_version.number == "3.0"
          OperationalDataExtractor::Birth::BIRTH_VISIT_3_PREFIX
        else
          OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX
        end
      end
    end

    def multiple_identifier
      case @response_set.survey.title
      when /_PregVisit1/
        "MULTIPLE_GESTATION"
      else
        "MULTIPLE"
      end
    end

    def birth_baby_name_prefix
      if /_Birth_INT_LI_/ =~ @response_set.survey.title
        OperationalDataExtractor::Birth::BABY_NAME_LI_PREFIX
      else
        OperationalDataExtractor::Birth::BABY_NAME_PREFIX
      end
    end

    ##
    # true if response to MULTIPLE is no or not yet responded OR if no response to MULTIPLE exists and no information on the children for current participant
    # false if response to MULTIPLE is yes OR if no response to MULTIPLE exists and participant has more than one child
    def single_birth?
      q = "#{multiple_release_birth_visit_prefix}.#{multiple_identifier}"
      multiple = response_for(q).to_s.downcase
      if multiple.blank?
        # defaulting to single_birth = true, if no information on the number of children, and event has no reference to multiple gestation question.
        if participant
          return participant.children.count <= 1
        else
          return true
        end
      else
        multiple.eql?("no") || multiple.eql?("singleton")
      end
    end

    def baby_sex_response
      response_for("#{birth_baby_name_prefix}.BABY_SEX").downcase
    end

    ##
    # true if not a single birth
    def multiple_birth?
      !single_birth?
    end

    # {baby/babies}
    def baby_babies
      single_birth? ? "baby" : "babies"
    end

    def baby_babies_upcase
      single_birth? ? "BABY" : "BABIES"
    end

    # {BABY’S/BABIES’}
    def babys_babies
      single_birth? ? "baby's" : "babies'"
    end

    def has_baby_have_babies
      single_birth? ? "HAS THE BABY" : "HAVE THE BABIES"
    end

    # {B_NAME/your baby}
    def b_fname
      if NcsNavigatorCore.mdes.version.to_f >= 3.0
        result = c_fname
      else
        result = response_for("#{birth_baby_name_prefix}.BABY_FNAME")
      end
      if result.empty?
        result = 'your baby'
      end
      result
    end

    # {B_NAME/your baby/your babies}
    def b_fname_or_babies
      single_birth? ? b_fname : "your babies"
    end

    # {Do/Does}
    def do_does
      single_birth? ? "Does" : "Do"
    end

    # {Have/Has}
    def have_has
      single_birth? ? "Has" : "Have"
    end

    def has_have_upcase
      single_birth? ? "HAS" : "HAVE"
    end

    def is_are
      single_birth? ? "Is" : "Are"
    end

    def was_were
      "was/were"
    end

    # {do/does}
    def do_does_downcase
      do_does.downcase
    end

    # {he/she/they}
    def he_she_they
      single_birth? ? baby_sex(baby_sex_response) : 'they'
    end

    # {his/her/their}
    def his_her_their
      single_birth? ? baby_sex_possessive(baby_sex_response) : "their"
    end

    def his_her_their_upcase
      his_her_their.upcase
    end

    # {he/she}
    def he_she
      baby_sex(baby_sex_response)
    end

    def he_she_upcase
      he_she.upcase
    end

    def he_she_the_child
      baby_sex(baby_sex_response, "the child")
    end

    def baby_sex_possessive(gender)
      case gender
      when "male"
        "his"
      when "female"
        "her"
      else
        "his/her"
      end
    end
    private :baby_sex_possessive


    def baby_sex(gender, default = "he/she")
      case gender
      when "male"
        "he"
      when "female"
        "she"
      else
        default
      end
    end
    private :baby_sex


    ### Pregnancy Visits ###

    def pregnancy_visit_prefix
      if /_Birth_INT_LI_/ =~ @response_set.survey.title
        OperationalDataExtractor::Birth::BIRTH_LI_PREFIX
      else
        OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX
      end
    end

    def f_fname
      father_full_name = response_for("#{OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_NAME")
      father_full_name.blank? ? "the father" : father_full_name.split(' ')[0]
    end

    ### Post Natal ###

    # TODO: Update the post natal methods with information that is obtained from previous instruments

    def child_children
      single_birth? ? "Child" : "Children"
    end

    def child_children_downcast
      child_children.downcase
    end

    def about_person
      @response_set.participant.try(:person)
    end

    def c_full_name
      (about_person.blank? || about_person.full_name.blank?) ? "[CHILD'S FULL NAME]" : about_person.full_name
    end

    def c_fname
      child_first_name("your baby")
    end

    def child_first_name_the_child
      child_first_name("the child")
    end

    def child_first_name_the_child_upcase
      child_first_name_the_child.upcase
    end

    def child_first_name_the_child_the_children
      single_birth? ? child_first_name_the_child : "the children"
    end

    def child_first_name_your_child
      child_first_name("your child")
    end

    def child_first_name_your_child_upcase
      child_first_name("your child").upcase
    end

    def child_first_name_your_baby
      child_first_name("your baby")
    end

    def child_first_name(txt)
      return txt if participant.blank?
      if participant.child_participant?
        result = participant.person.first_name unless participant.person.try(:first_name).blank?
      else
        result = participant.children.first.first_name unless participant.children.blank?
      end
      result.blank? ? txt : result
    end

    def child_first_name_through_participant(txt)
      participant.children.blank? ? txt : participant.children.map{|c| c.first_name}.join(',')
    end

    private :child_first_name

    def child_primary_address
      default = "[CHILD'S PRIMARY ADDRESS]"
      result = about_person.blank? ? default : about_person.primary_address.to_s
      result.blank? ? default : result
    end

    def child_secondary_address
      default = "[CHILD'S SECONDARY ADDRESS]"
      result = about_person.blank? ? default : about_person.secondary_address.to_s
      result.blank? ? default : result
    end

    def child_secondary_number
      default = "[SECONDARY PHONE NUMBER]"
      result = about_person.blank? ? default : format_phone_number(about_person.secondary_phone.to_s)
      result.blank? ? default : result
    end

    def c_fname_or_the_child
      (about_person.blank? || about_person.first_name.blank?) ? "the Child" : about_person.first_name
    end

    def c_dob
      return about_person.person_dob if about_person.present? && about_person.person_dob
      "[CHILD'S DATE OF BIRTH]"
    end

    def does_participants_children_have_date_of_birth?(participant)
      if (participant.children.blank? || participant.children.first.blank? || participant.children.first.person_dob.blank?)
        false
      else
        true
      end
    end

    def c_dob_through_participant
      !does_participants_children_have_date_of_birth?(participant) ? "[CHILD'S DATE OF BIRTH]" : participant.children.first.person_dob
    end

    def age_of_child_in_months(today = Date.today)
      return "[AGE OF CHILD IN MONTHS]" if about_person.blank? || about_person.person_dob.blank?
      begin
        dob = Date.parse(about_person.person_dob)
        result = (today.year*12 + today.month) - (dob.year*12 + dob.month)
        dob.day > today.day ? (result-1) : result
      rescue
        return "[AGE OF CHILD IN MONTHS]"
      end
    end

    def work_place_name
      default = "[PARTICIPANTS WORKPLACE NAME]"
      result = response_for("PREG_VISIT_1_3.WORK_NAME")
      if result.blank?
        result = response_for("PREG_VISIT_2_3.WORK_NAME")
      end
      result.blank? ? default : result
    end

    def work_address
      default = "[WORK ADDRESS]"
      result = about_person.blank? ? default : about_person.primary_work_address.to_s
      result.blank? ? default : result
    end

    #PBSamplingScreen_INT_PBS_M3.0_V1.0.rb
    #q_FIRST_VISIT "Was your visit on {{date_of_visit}} your first visit to this office to see the doctor, nurse, or midwife for this pregnancy?",
    #    •	IF MODE = CAPI OR PAPI, DISPLAY “Is your visit today”.
    #    •	IF MODE = CATI, DISPLAY “Was your visit on” AND PRELOAD AND DISPLAY DATE OF VISIT.
    #Nataliya's comment - it's unclear what DATE OF VISIT should be.
    def date_of_visit
      "[DATE OF VISIT]"
    end

    #Nataliya's comment, make sense to remove this method and call local_study_affiliate in mustache instead. Leaving it as is now
    def institution
      default = "[INSTITUTION]"
      result = local_study_affiliate
      result.blank? ? default : result
    end

    def practice_name
      about_person.blank? || about_person.provider.blank? ? '[PRACTICE_NAME]' : about_person.provider.try(:name_practice)
    end

    def county
      county_from_psu = NcsCode.for_list_name_and_local_code("PSU_CL1", NcsNavigatorCore.psu)
      filter_out_wave_number_from_psu(county_from_psu)
    end

    def filter_out_wave_number_from_psu(display_text)
      display_text.to_s.gsub(/\s*\(Wave \d+\)$/, '')
    end

    # IF BIRTH_DELIVER = 1, DISPLAY “HOSPITAL” THROUGHOUT THE INSTRUMENT.
    # IF BIRTH_DELIVER = 2, DISPLAY “BIRTHING CENTER” THROUGHOUT THE INSTRUMENT.
    # IF BIRTH_DELIVER = -5, DISPLAY “OTHER PLACE” THROUGHOUT THE INSTRUMENT.
    def birthing_place
      result = response_for("#{multiple_release_birth_visit_prefix}.BIRTH_DELIVER")
      result.blank? ? result : result.downcase.gsub(/some\s+/i, '')
    end

    def birthing_place_upcase
      birthing_place.upcase
    end

    # For Birth_INT_3.0
    # • IF MULTIPLE = 1 AND MULTIPLE_NUM = 2 AND FIRST LOOP, DISPLAY: “First let’s talk about your first twin birth.”
    # • IF MULTIPLE = 1 AND MULTIPLE_NUM = 3 AND FIRST LOOP, DISPLAY: “First let’s talk about your first triplet birth.”
    # • IF MULTIPLE = 1 AND MULTIPLE_NUM ≥ 4 AND FIRST LOOP, DISPLAY: “First, let’s talk about your first higher order birth.”
    # • IF MULTIPLE = 1 AND MULTIPLE_NUM = 2 AND SECOND LOOP, OR
    # • IF MULTIPLE = 1 AND MULTIPLE_NUM ≥ 3 AND SECOND OR HIGHER LOOP, DISPLAY: “Now let’s talk about your next baby.”
    # • IF MULTIPLE =2, DISPLAY: “Let’s talk about your baby.”
    def lets_talk_about_baby
      result = ""
      if single_birth?
        result = "Let’s talk about your baby."
      else
        multiple_num = response_for("#{OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX}.MULTIPLE_NUM")
        if about_person.first_child?
          if( multiple_num.eql?("2") || multiple_num.eql?("02") )
            result = "First let’s talk about your first twin birth."
          elsif ((multiple_num.eql? "3") || (multiple_num.eql? "03"))
            result = "First let’s talk about your first triplet birth."
          else
            result = "First, let’s talk about your first higher order birth."
          end
        else
          result = "Now let’s talk about your next baby."
        end
      end
      result
    end

    # For Birth_INT_3.0
    # • IF MULTIPLE = 2 AND VALID RESPONSE PROVIDED FOR C_FNAME AND EITHER RELEASE=1 OR BIRTH_DELIVER = 3, DISPLAY “Does C_FNAME”.
    # • IF MULTIPLE = 2 AND VALID RESPONSE NOT PROVIDED FOR C_FNAME = AND EITHER RELEASE=1 OR BIRTH_DELIVER = 3, DISPLAY “Does your baby”.
    # • IF MULTIPLE = 1 AND EITHER RELEASE=1 OR BIRTH_DELIVER = 3, DISPLAY “Do your babies”.
    # • IF MULTIPLE = 2 AND RELEASE = 2 AND VALID RESPONSE PROVIDED FOR C_FNAME, DISPLAY “When C_FNAME leaves the” .
    # • IF MULTIPLE = 2 AND RELEASE = 2 AND VALID RESPONSE NOT PROVIDED FOR C_FNAME, DISPLAY “When your baby leaves the”.
    # • IF MULTIPLE = 1 AND RELEASE = 2, DISPLAY “your babies leave”.
    # • IF MULTIPLE = 1, DISPLAY “they”.
    def do_when_will_live_with_you
      result = "[Does [C_FNAME/your baby]]/[Do your babies]/[When [C_FNAME/your babies] leave the]/[When your baby leaves the] [hospital/ birthing center/ other place] will [he/she/they] live with you?"

      return result unless multiple_release_birth_visit_prefix

      released = response_for("#{multiple_release_birth_visit_prefix}.RELEASE") #a_1 "YES" a_2 "NO"
      birth_deliver = response_for("#{multiple_release_birth_visit_prefix}.BIRTH_DELIVER") #a_1 "HOSPITAL" a_2 "BIRTHING CENTER" a_3 "AT HOME" a_neg_5 "SOME OTHER PLACE"
      if single_birth? #MULTIPLE = 2
        if ((released.upcase.eql? "YES") || (birth_deliver.upcase.eql? "AT HOME"))
          result = "Does " + child_first_name_through_participant("your baby") + " live with you?"
        end
        if released.upcase.eql? "NO"
          result = "When " + child_first_name_through_participant("your baby") + " leaves the " + birthing_place + " will " + he_she_they + " live with you?"
        end
      else
        if ((released.upcase.eql? "YES") || (birth_deliver.upcase.eql? "AT HOME"))
          result = "Do your babies live with you?"
        end
        if released.upcase.eql? "NO"
          result = "When your babies leave the "+ birthing_place + " will " + he_she_they + " live with you?"
        end
      end
      result
    end
    # Used in PBSamplingScreener 3.0, in reference to the gender of a provider the
    # participant may have visited

    # Nataliya's comment - this should not be part of the context
    def his_her
      "[his_her]"
    end

    def stomach_back_side
      single_birth? ? "stomach, back and side" : "stomachs, backs and sides"
    end

    def participant
      @response_set.participant
    end

    def date_of_preg_visit_1
      participant.completed_events.select{|e| e.event_type_code == 13}.map{|e| e.event_end_date}.sort.last
    end

    def date_of_preg_visit_2
      participant.completed_events.select{|e| e.event_type_code == 15}.map{|e| e.event_end_date}.sort.last
    end

    def in_the_past
      participant.completed_events.select{|e| e.event_type_code == 13}.blank? ? "in the past" : ""
    end

    def since
      participant.completed_events.select{|e| e.event_type_code == 13}.blank? ? "" : "since"
    end

    def ever
      participant.completed_events.select{|e| e.event_type_code == 13}.blank? ? "ever" : ""
    end

    # For PART_TWO_BIRTH_3_0 Medical History handle:
    # • IF PV2 VISIT FOR CURRENT PREGNANCY SET TO COMPLETE, PRELOAD DATE OF PV2 VISIT.
    # • IF PV1 VISIT FOR CURRENT PREGNANCY SET TO COMPLETE, BUT PV2 VISIT NOT SET TO COMPLETE, PRELOAD DATE OF PV1 VISIT.
    def date_of_last_pv_visit
      result = "[DATE OF PV1 VISIT/DATE OF PV2 VISIT]"
      if not date_of_preg_visit_2.blank?
        result = date_of_preg_visit_2
      else
        if not date_of_preg_visit_1.blank?
          result = date_of_preg_visit_1
        end
      end
      result
    end

    def date_of_last_interview
      "[DATE OF LAST INTERVIEW]"
    end

    def event_type_code
      @response_set.instrument.event.event_type_code
    end

    # IF EVENT_TYPE = PREGNANCY VISIT 1, PREGNANCY VISIT 2, OR FATHER, PRELOAD EVENT_TYPE
    def event_type
      event_type = @response_set.instrument.event.event_type.to_s
      event_type = "[EVENT_TYPE]" if event_type.blank?
      event_type
    end

    def event_type_upcase
      event_type.upcase
    end

    def and_birth_date
      "and birth date"
    end

    # guardian_name is composed of g_fname, g_mname, and g_lname
    def are_you_or_is_guardian_name
      "[ARE_YOU_OR_IS_GUARDIAN_NAME]"
    end

    #Nataliya's comment - not used anywhere
    def primary_address
      "[PRIMARY_ADDRESS]"
    end

    #Nataliya's comment = what is this for? We have already is_are - is this upcase??? Only have lower case method in instruments.
    def is_are_upcase
      is_are.upcase
    end

    #Nataliya's comment - not found anywhere
    def secondary_phone_number
      "[SECONDARY_PHONE_NUMBER]"
    end

    # Used in Participant Verification 3.0, return correct either correct name
    # or correct name and birth date if birth date has not been previously collected
    def correct_name_and_birth_date
      result = '[CORRECT_NAME_AND_BIRTH_DATE]'

      if about_person.try(:first_name)
        result = 'correct name'
      end

      if about_person.try(:person_dob)
        result += ' and birth date'
      end

      result
    end

    def himself_herself
      case baby_sex_response
      when "male"
        "himself"
      when "female"
        "herself"
      else
        "himself/herself"
      end
    end

    def him_her
      case baby_sex_response
      when "male"
        "him"
      when "female"
        "her"
      else
        "him/her"
      end
    end

    def medicaid_name
      "[STATE MEDICAID NAME]"
    end

    def schip_name
      "[STATE CHILD HEALTH INSURANCE PROGRAM NAME]"
    end

    def child_sex
      response_for("PARTICIPANT_VERIF_CHILD.CHILD_SEX")
    end

    def boys_girls
      case child_sex
      when "MALE"
        "boys"
      when "FEMALE"
        "girls"
      else
        "boys/girls"
      end
    end

    def approximate_visit_time_table(event_code, recruitment_type)
      avtt = {
        Event::pregnancy_visit_1_code => {
          "EnhancedHousehold"  => "1.5 hours",
          "ProviderBased"  => "1.5 hours",
          "HighIntensity"  => "1.5 hours",
          "LowIntensity"  => "1 hour",
          "ProviderBasedSubsample" => "1 hour"
        },
        Event::pregnancy_visit_2_code => {
          "EnhancedHousehold"  => "1.5 hours",
          "ProviderBased"  => "1.5 hours",
          "HighIntensity"  => "1.5 hours",
          "LowIntensity"  => "1 hour",
          "ProviderBasedSubsample" => "1 hour"
        },
        Event::father_visit_code => {
          "EnhancedHousehold"  => "1.75 hours",
          "ProviderBased"  => "1.75 hours",
          "HighIntensity"  => "1.75 hours"
        },
        Event::birth_code => {
          "EnhancedHousehold"  => "45 minutes",
          "ProviderBased"  => "45 minutes",
          "HighIntensity"  => "45 minutes",
          "ProviderBasedSubsample" => "45 minutes",
          "LowIntensity"  => "30 minutes"
        },
        Event::three_month_visit_code => {
          "EnhancedHousehold"  => "40 minutes",
          "ProviderBased"  => "40 minutes",
          "HighIntensity"  => "40 minutes",
          "ProviderBasedSubsample" => "40 minutes",
          "LowIntensity"  => "40 minutes"
        },
        Event::six_month_visit_code => {
          "EnhancedHousehold"  => "2 hours",
          "ProviderBased"  => "2 hours",
          "HighIntensity"  => "2 hours",
          "ProviderBasedSubsample" => "1.5 hours"
        },
        Event::nine_month_visit_code => {
          "EnhancedHousehold"  => "35 minutes",
          "ProviderBased"  => "35 minutes",
          "HighIntensity"  => "35 minutes",
          "ProviderBasedSubsample" => "35 minutes",
        },
        Event::twelve_month_visit_code => {
          "EnhancedHousehold"  => "2 hours",
          "ProviderBased"  => "2 hours",
          "HighIntensity"  => "2 hours",
          "ProviderBasedSubsample" => "1 hour"
        },
        Event::eighteen_month_visit_code => {
          "EnhancedHousehold"  => "45 minutes",
          "ProviderBased"  => "45 minutes",
          "HighIntensity"  => "45 minutes",
          "ProviderBasedSubsample" => "45 minutes",
          "LowIntensity"  => "45 minutes"
        },
        Event::twenty_four_month_visit_code => {
          "EnhancedHousehold"  => "1.5 hours",
          "ProviderBased"  => "1.5 hours",
          "HighIntensity"  => "1.5 hours",
          "ProviderBasedSubsample" => "45 minutes",
          "LowIntensity"  => "45 minutes"
        },
        Event::thirty_six_month_visit_code => {
          "EnhancedHousehold"  => "1.75 hours",
          "ProviderBased"  => "1.75 hours",
          "HighIntensity"  => "1.75 hours",
          "LowIntensity"  => "1.75 hour",
          "ProviderBasedSubsample" => "1.75 hour"
        },
      }

      if event_code && recruitment_type
        avtt[event_code][recruitment_type]
      else
        "unknown amount of time"
      end
    end

    def hi_lo
      @response_set.participant.high_intensity? ? "HighIntensity" : "LowIntensity"
    end

    def get_recruitment_strategy
      recruitment_type = NcsNavigatorCore.recruitment_strategy.class.name
      case recruitment_type
      when "TwoTier"
        hi_lo
      when "ProviderBased", "EnhancedHousehold", "ProviderBasedSubsample"
        recruitment_type
      else
        nil
      end
    end

    def approximate_visit_time
      result = approximate_visit_time_table(
                        @response_set.instrument.event.try(:event_type_code),
                        get_recruitment_strategy)
    end

  end

end

class InvalidStateException < StandardError; end
