# -*- coding: utf-8 -*-


class DispositionMapper

  PROVIDER_RECRUITED = 70
  PROVIDER_REFUSED   = [46,47,48,49,50,51,52,53]

  HOUSEHOLD_ENUMERATION_EVENT = "Household Enumeration Event"   #1
  PREGNANCY_SCREENER_EVENT    = "Pregnancy Screener Event"      #2
  GENERAL_STUDY_VISIT_EVENT   = "General Study Visit Event"     #3
  MAILED_BACK_SAQ_EVENT       = "Mailed Back SAQ Event"         #4
  TELEPHONE_INTERVIEW_EVENT   = "Telephone Interview Event"     #5
  INTERNET_SURVEY_EVENT       = "Internet Survey Event"         #6
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

    ##
    # Given a Survey title or mode of Contact as a String
    # parameter, return the disposition category (one of the
    # constants for this class).
    # @param group [String]
    # @return [String]
    def determine_event(group)
      case group
      when /_PregScreen_/
        PREGNANCY_SCREENER_EVENT
      when /Telephone/
        TELEPHONE_INTERVIEW_EVENT
      when /Text Message/
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

    ##
    # Determine the disposition text for the given category and
    # disposition code
    # @param[NcsCode] - 'EVENT_DSPSTN_CAT_CL1'
    # @param[Integer] - the Disposition Status Code (Interim)
    # @return[String] - the text associated with that code in that category
    def disposition_text(category, code)
      return code if category.blank? || category.local_code.to_i < 0
      key = get_key_from_event_disposition_category(category)
      if opts = get_grouped_options[key]
        match = opts.select { |k,v| v == code }.first
        match[0] if match
      end
    end

    ##
    # Determine the disposition text for the given Event
    # @see #disposition_text
    # @param[Event] - to determine disposition category and code
    # @return[String]
    def disposition_text_for_event(event)
      disposition_text(event.event_disposition_category, event.event_disposition)
    end

    ##
    # Check if an event or contact's event is associated with a
    # disposition code
    def find_events_category(contact, event)
      if event
        determine_category_from_event_type(event.try(:event_type_code))
      else
        contact.event_disposition_category_for_contact
      end
    end
    private :find_events_category

    ##
    # Determine the disposition text for the given Contact for
    # the given Event
    # @see #disposition_text
    # @param[Contact] - to determine category and code (if Event does not determine category)
    # @param[Event] - to determine category (if Event determines category)
    # @return[String] - the text associated with that code in that category
    def disposition_text_for_contact(contact, event = nil)
      if event_category = find_events_category(contact, event)
        disposition_text(event_category, contact.contact_disposition)
      elsif category = determine_category_from_contact_type(
                                                contact.contact_type_code)
        disposition_text(category, contact.contact_disposition)
      else
        contact.contact_disposition
      end
    end

    ##
    # Given a code from the 'CONTACT_TYPE_CL1' code list
    # determine the associated 'EVENT_DSPSTN_CAT_CL1' and
    # return that NcsCode
    #
    # CONTACT_TYPE_CL1    | EVENT_DSPSTN_CAT_CL1
    # 1 In person         | 3 General Study Visits (including CASI SAQs)
    # 2 Mail              | 4 Mailed Back Self Administered Questionnaires
    # 3 Telephone         | 5 Telephone Interview Events
    # 4 Email             | 3 General Study Visits (including CASI SAQs)
    # 5 Text Message      | 5 Telephone Interview Events
    # 6 Website           | 3 General Study Visits (including CASI SAQs)
    #
    # @param[Integer] - CONTACT_TYPE_CL1
    # @return[NcsCode] - EVENT_DSPSTN_CAT_CL1
    def determine_category_from_contact_type(code)
      case code
      when 1,4,6
        NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 3)
      when 2
        NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 4)
      when 3,5
        NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 5)
      else
        nil
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

    ##
    # If the event type determines the category, return the Event
    # Disposition Category NcsCode.
    # Returns nil if the event type does not determine the category
    # @param[Integer] - EVENT_TYPE_CL1
    # @return[NcsCode] - EVENT_DSPSTN_CAT_CL1
    def determine_category_from_event_type(event_type_code)
      return nil if event_type_code.blank?
      case event_type_code
      when Event.household_enumeration_code
        NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 1)
      when Event.pregnancy_screener_code
        NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 2)
      when Event.provider_recruitment_code
        NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 7)
      when Event.pbs_eligibility_screener_code
        NcsCode.for_list_name_and_local_code('EVENT_DSPSTN_CAT_CL1', 8)
      else
        nil
      end
    end


  end

end
