# -*- coding: utf-8 -*-

require 'ncs_navigator/core/mustache'
require 'mustache'

module NcsNavigator::Core::Mustache

  ##
  # This is an instrument context object that provides a
  # Mustache object with keys known to NCS instruments.
  class InstrumentContext < ::Mustache

    attr_accessor :response_set

    def initialize(response_set)
      @response_set = response_set
    end

    def response_for(data_export_identifier)
      Response.includes([:answer, :question, :response_set]).
                where("response_sets.user_id = ? AND questions.data_export_identifier = ?",
                      @response_set.person.id, data_export_identifier).last.to_s
    end

    ### Birth Instruments ###

    # BABY_NAME_PREFIX    = "BIRTH_VISIT_BABY_NAME_2"
    # BIRTH_VISIT_PREFIX  = "BIRTH_VISIT_2"
    # BABY_NAME_LI_PREFIX = "BIRTH_VISIT_LI_BABY_NAME"
    # BIRTH_LI_PREFIX     = "BIRTH_VISIT_LI"

    def birth_instrument_multiple_prefix
      if /_Birth_INT_LI_/ =~ @response_set.survey.title
        BirthOperationalDataExtractor::BIRTH_LI_PREFIX
      else
        BirthOperationalDataExtractor::BIRTH_VISIT_PREFIX
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
      multiple = response_for("#{birth_instrument_multiple_prefix}.MULTIPLE")
      multiple.blank? || multiple.downcase.eql?("no")
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

  end

end