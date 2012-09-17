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
      @response_set.person.try(:full_name)
    end

    def p_dob
      @response_set.person.try(:person_dob)
    end

    def p_phone_number
      if person = @response_set.try(:person)
        home_phone = person.primary_home_phone
        cell_phone = person.primary_cell_phone
        home_phone ? home_phone : cell_phone
      end
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
        PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_INTERVIEW_PREFIX
      when /_Birth_INT_LI_/
        BirthOperationalDataExtractor::BIRTH_LI_PREFIX
      else
        BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX
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
        BirthOperationalDataExtractor::BABY_NAME_LI_PREFIX
      else
        BirthOperationalDataExtractor::BABY_NAME_PREFIX
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

    # {BABY’S/BABIES’}
    def babys_babies
      single_birth? ? "baby's" : "babies'"
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
        BirthOperationalDataExtractor::BIRTH_LI_PREFIX
      else
        BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX
      end
    end

    def f_fname
      father_full_name = response_for("#{PregnancyVisitOperationalDataExtractor::PREGNANCY_VISIT_1_SAQ_PREFIX}.FATHER_NAME")
      father_full_name.blank? ? "the father" : father_full_name.split(' ')[0]
    end

    ### Post Natal ###

    # TODO: Update the post natal methods with information that is obtained from previous instruments

    def child_children
      "[Child or Children]"
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

    def child_first_name(txt)
      about_person.blank? ? txt : about_person.first_name
    end
    private :child_first_name

    def c_dob
      about_person.blank? ? "[CHILD'S DATE OF BIRTH]" : about_person.person_dob
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