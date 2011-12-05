class DispositionMapper

  GENERAL_STUDY_VISIT_EVENT   = "General Study Visit Event"
  HOUSEHOLD_ENUMERATION_EVENT = "Household Enumeration Event"
  INTERNET_SURVEY_EVENT       = "Internet Survey Event"
  MAILED_BACK_SAQ_EVENT       = "Mailed Back SAQ Event"
  PREGNANCY_SCREENER_EVENT    = "Pregnancy Screener Event"
  TELEPHONE_INTERVIEW_EVENT   = "Telephone Interview Event"
  EVENTS =  [
              GENERAL_STUDY_VISIT_EVENT,
              HOUSEHOLD_ENUMERATION_EVENT,
              INTERNET_SURVEY_EVENT,
              MAILED_BACK_SAQ_EVENT,
              PREGNANCY_SCREENER_EVENT,
              TELEPHONE_INTERVIEW_EVENT
            ]

  class << self

    def get_grouped_options(group = nil)
      grouped_options = {}
      mdes = NcsNavigatorCore.mdes
      mdes.disposition_codes.map(&:event).uniq.each do |event|
        grouped_options[event] = [] if should_add(group, event)
      end

      mdes.disposition_codes.each do |code|
        grouped_options[code.event] << [code.disposition, code.final_code] if grouped_options.has_key?(code.event)
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
      when /Telephone/
        TELEPHONE_INTERVIEW_EVENT
      when /Mail/
        MAILED_BACK_SAQ_EVENT
      when /_SAQ_/
        MAILED_BACK_SAQ_EVENT
      when /_HHEnum_/
        HOUSEHOLD_ENUMERATION_EVENT
      when /_PregScreen_/
        PREGNANCY_SCREENER_EVENT
      else
        GENERAL_STUDY_VISIT_EVENT
      end
    end

    # Contact Type
    # In-person, Mail, Telephone, Email, Text Message, Website, Other

  end

end
