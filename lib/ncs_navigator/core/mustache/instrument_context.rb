# -*- coding: utf-8 -*-


require 'ncs_navigator/core/mustache'
require 'mustache'

module NcsNavigator::Core::Mustache

  ##
  # This is an instrument context object that provides a
  # Mustache object with keys known to NCS instruments.
  class InstrumentContext < ::Mustache

    attr_accessor :response_set
    attr_accessor :current_user

    def initialize(response_set = nil)
      @response_set = response_set
    end

    def response_for(data_export_identifier)
      raise InvalidStateException, "No response set exists for this Instrument Context" unless @response_set
      Response.includes([:answer, :question, :response_set]).
                where("response_sets.user_id = ? AND questions.data_export_identifier = ?",
                      @response_set.person.id, data_export_identifier).last.to_s
    end

    ### Current Logged in User ###

    def current_user=(usr)
      @current_user = usr
    end

    def current_user
      @current_user
    end

    def interviewer_name
      @current_user ? @current_user.full_name : "[INTERVIEWER NAME]"
    end

    ### Person taking survey ###

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
        cell_phone = person.primary_cell_phone if person.primary_cell_phone
      end
      cell_phone
    end

    def p_home_phone
      home_phone = "[HOME PHONE NUMBER]"
      if person = @response_set.try(:person)
        home_phone = person.primary_home_phone if person.primary_home_phone
      end
      home_phone
    end

    def p_phone_number
      if person = @response_set.try(:person)
        home_phone = p_home_phone
        cell_phone = p_cell_phone

        result = nil
        result = cell_phone unless cell_phone == "[CELL PHONE NUMBER]"
        result = home_phone unless home_phone == "[HOME PHONE NUMBER]"
        result
      end
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
      result = response_for("PARTICIPANT_VERIF.NAME_CONFIRM")
      if result.blank?
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
    # BABY_NAME_LI_PREFIX = "BIRTH_VISIT_LI_BABY_NAME"
    # BIRTH_LI_PREFIX     = "BIRTH_VISIT_LI"

    def multiple_birth_prefix
      case @response_set.survey.title
      when /_PregVisit1/
        OperationalDataExtractor::PregnancyVisit::PREGNANCY_VISIT_1_INTERVIEW_PREFIX
      when /_Birth_INT_LI_/
        OperationalDataExtractor::Birth::BIRTH_LI_PREFIX
      else
        OperationalDataExtractor::Birth::BIRTH_VISIT_PREFIX
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
    # true if response to MULTIPLE is no or not yet responded
    def single_birth?
      multiple = response_for("#{multiple_birth_prefix}.#{multiple_identifier}").to_s.downcase
      multiple.blank? || (multiple.eql?("no") || multiple.eql?("singleton"))
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
      result = response_for("#{birth_baby_name_prefix}.BABY_FNAME")
      result = 'your baby' if result.blank?
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

    # {he/she}
    def he_she
      baby_sex(baby_sex_response)
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


    def baby_sex(gender)
      case gender
      when "male"
        "he"
      when "female"
        "she"
      else
        "he/she"
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

    def about_person
      @response_set.participant.try(:person)
    end

    def c_full_name
      about_person.blank? ? "[CHILD'S FULL NAME]" : about_person.full_name
    end

    def c_fname
      child_first_name("[CHILD'S FIRST NAME]")
    end

    def child_first_name_the_child
      child_first_name("the child")
    end

    def child_first_name_your_baby
      child_first_name("your baby")
    end

    def child_first_name(txt)
      about_person.blank? ? txt : about_person.first_name
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
      result = about_person.blank? ? default : about_person.secondary_phone.to_s
      result.blank? ? default : result
    end

    def c_fname_or_the_child
      about_person.blank? ? "the Child" : about_person.first_name
    end

    def c_dob
      about_person.blank? ? "[CHILD'S DATE OF BIRTH]" : about_person.person_dob
    end

    def work_place_name
      result = "[PARTICIPANTS WORKPLACE NAME]"
      if (event_type == 15)
        result = response_for("PREG_VISIT_2_3.WORK_NAME")
      end
      if (event_type == 18)
        result = response_for("BIRTH_VISIT_3.WORK_NAME")
      end
      result
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
      local_study_affiliate
    end

    def practice_name
      response_for("PBS_ELIG_SCREENER.PRACTICE_NAME")
    end

    def county
      NcsCode.for_list_name_and_local_code("PSU_CL1", NcsNavigatorCore.psu)
    end

    def birthing_place
      response_for("BIRTH_VISIT_3.BIRTH_DELIVER")
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
          if ((multiple_num.eql? ("2")) || (multiple_num.eql?("02")))
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
      result = "[Does [C_FNAME/your baby]]/[Do your babies]/[When [C_FNAME/your babies] leave the]/[When your baby leaves the] [hospital/ birthing center/ other place] will [he/she/they] live with you?",
      released = response_for("BIRTH_VISIT_3.RELEASE") #a_1 "YES" a_2 "NO"
      birth_deliver = response_for("BIRTH_VISIT_3.BIRTH_DELIVER") #a_1 "HOSPITAL" a_2 "BIRTHING CENTER" a_3 "AT HOME" a_neg_5 "SOME OTHER PLACE"
      if single_birth? #MULTIPLE = 2
        if ((released.upcase.eql? "YES") || (birth_deliver.upcase.eql? "AT HOME"))
          result = "Does " + child_first_name_your_baby + " live with you?"
        end
        if released.upcase.eql? "NO"
          result = "When " + child_first_name_your_baby + " leaves the " + birthing_place + " will " + he_she_they + " live with you?"
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
      participant.completed_events(13).map{|e| e.event_end_date}.sort.last
    end

    def date_of_preg_visit_2
      participant.completed_events(15).map{|e| e.event_end_date}.sort.last
    end

    def in_the_past
      participant.completed_events(13).blank? ? "in the past" : ""
    end

    def since
      participant.completed_events(13).blank? ? "" : "since"
    end

    def ever
      participant.completed_events(13).blank? ? "ever" : ""
    end

    # For PART_TWO_BIRTH_3_0 Medical History handle:
    # • IF PV2 VISIT FOR CURRENT PREGNANCY SET TO COMPLETE, PRELOAD DATE OF PV2 VISIT.
    # • IF PV1 VISIT FOR CURRENT PREGNANCY SET TO COMPLETE, BUT PV2 VISIT NOT SET TO COMPLETE, PRELOAD DATE OF PV1 VISIT.
    def date_of_last_pv_visit
      result = "[DATE OF PV1 VISIT/DATE OF PV2 VISIT]"
      if not date_of_preg_visit_2.blank?
        result = date_of_preg_visit_2
        if not date_of_preg_visit_1.blank?
          result = date_of_preg_visit_1
        end
      end
      result
    end

    # IF EVENT_TYPE = PREGNANCY VISIT 1, PREGNANCY VISIT 2, OR FATHER, PRELOAD EVENT_TYPE
    def event_type
      event_type = @response_set.instrument.event.to_s
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

    #Nataliya's comment - this method should be eliminated. date_of_last_pv_visit should be used
    #The rest should be done with dependencies in the instruments, like in Birth
    def choose_date_range_for_birth_instrument
      if date_of_preg_visit_2
        return "between #{date_of_preg_visit_2} and #{c_dob}"
      elsif date_of_preg_visit_1
        return "between #{date_of_preg_visit_1} and #{c_dob}"
      else
        return "before #{c_dob}"
      end
    end

    #Nataliya's comment - this method should be eliminated. date_of_last_pv_visit should be used
    #The rest should be done with dependencies in the instruments, like in Birth
    def choose_date_range_for_birth_instrument_variation_1
      if date_of_preg_visit_2
        return "At this visit or at any time between #{date_of_preg_visit_2} and #{c_dob}"
      elsif date_of_preg_visit_1
        return "At this visit or at any time between #{date_of_preg_visit_1} and #{c_dob}"
      else
        return "At any time in your pregnancy"
      end
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
  end

end

class InvalidStateException < StandardError; end
