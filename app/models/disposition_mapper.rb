# -*- coding: utf-8 -*-


class DispositionMapper

  PROVIDER_RECRUITED = 70

  GENERAL_STUDY_VISIT_EVENT   = "General Study Visit Event"     #3
  HOUSEHOLD_ENUMERATION_EVENT = "Household Enumeration Event"   #2
  INTERNET_SURVEY_EVENT       = "Internet Survey Event"         #6
  MAILED_BACK_SAQ_EVENT       = "Mailed Back SAQ Event"         #4
  PREGNANCY_SCREENER_EVENT    = "Pregnancy Screener Event"      #1
  TELEPHONE_INTERVIEW_EVENT   = "Telephone Interview Event"     #5
  PROVIDER_RECRUITMENT_EVENT  = "Provider Recruitment"          #7
  PBS_ELIGIBILITY_EVENT       = "PBS Eligibility Screening"     #8

  EVENTS =  [
              GENERAL_STUDY_VISIT_EVENT,
              HOUSEHOLD_ENUMERATION_EVENT,
              INTERNET_SURVEY_EVENT,
              MAILED_BACK_SAQ_EVENT,
              PREGNANCY_SCREENER_EVENT,
              TELEPHONE_INTERVIEW_EVENT,
              PROVIDER_RECRUITMENT_EVENT,
              PBS_ELIGIBILITY_EVENT
            ]

  class << self

    def get_grouped_options(group = nil)
      grouped_options = {}
      mdes = NcsNavigatorCore.mdes
      mdes.disposition_codes.map(&:event).uniq.each do |event|
        grouped_options[event] = [] if should_add(group, event)
      end

      mdes.disposition_codes.each do |code|
        grouped_options[code.event] << [code.disposition, code.interim_code.to_i] if grouped_options.has_key?(code.event)
      end
      grouped_options
    end

    def should_add(group, event)
      result = false
      if group.nil?
        result = true
      elsif EVENTS.include?(group)
        result = (group == event)
      else
        result = (determine_event(group) == event)
      end
      result
    end
    private :should_add

    def determine_event(group)
      case group
      when /_PregScreen_/
        PREGNANCY_SCREENER_EVENT
      when /Telephone/
        TELEPHONE_INTERVIEW_EVENT
      when /Mail/
        MAILED_BACK_SAQ_EVENT
      when /_SAQ_/
        MAILED_BACK_SAQ_EVENT
      when /_HHEnum_/
        HOUSEHOLD_ENUMERATION_EVENT
      else
        GENERAL_STUDY_VISIT_EVENT
      end
    end

    def for_event_disposition_category_code(code)
      case code
      when 1
        HOUSEHOLD_ENUMERATION_EVENT
      when 2
        PREGNANCY_SCREENER_EVENT
      when 3
        GENERAL_STUDY_VISIT_EVENT
      when 4
        MAILED_BACK_SAQ_EVENT
      when 5
        TELEPHONE_INTERVIEW_EVENT
      when 6
        INTERNET_SURVEY_EVENT
      when 7
        PROVIDER_RECRUITMENT_EVENT
      when 8
        PBS_ELIGIBILITY_EVENT
      else
        GENERAL_STUDY_VISIT_EVENT
      end
    end

    # Contact Type
    # In-person, Mail, Telephone, Email, Text Message, Website, Other

    def disposition_text_for_event(category, code)
      return code if category.blank? || category.local_code.to_i < 0
      key = get_key_from_event_disposition_category(category)
      if opts = get_grouped_options[key]
        match = opts.select { |k,v| v == code }.first
        match[0] if match
      end
    end

    def get_key_from_event_disposition_category(category)
      result = nil
      part = category.to_s.split(' ').first
      # TODO: switch to full case stmt to handle the discrepancies between
      #       event name and disposition category
      case part
      when 'Provider-Based'
        result = PROVIDER_RECRUITMENT_EVENT
      else
        EVENTS.each do |e|
          result = e if e.split(' ').first == part
        end
      end
      result
    end

  end

end