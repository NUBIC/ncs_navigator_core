# -*- coding: utf-8 -*-

class SimplePostNatalOperationalDataExtractor

  THREE_MONTH_MOTHER_PREFIX  = "THREE_MTH_MOTHER_CHILD_DETAIL"
  NINE_MONTH_MOTHER_PREFIX   = "NINE_MTH_MOTHER_DETAIL"

  CHILD_PERSON_NAME_MAP = {
    "#{THREE_MONTH_MOTHER_PREFIX}.C_FNAME"       =>"first_name",
    "#{THREE_MONTH_MOTHER_PREFIX}.C_LNAME"       =>"last_name",
    "#{NINE_MONTH_MOTHER_PREFIX}.C_FNAME"       =>"first_name",
    "#{NINE_MONTH_MOTHER_PREFIX}.C_LNAME"       =>"last_name",
  }

  CHILD_PERSON_DATE_OF_BIRTH_MAP = {
    "#{THREE_MONTH_MOTHER_PREFIX}.CHILD_DOB"     =>"person_dob",
    "#{NINE_MONTH_MOTHER_PREFIX}.CHILD_DOB"     =>"person_dob",
  }

  class << self

    def extract_data(response_set)

      person = response_set.person
      if person.participant.blank?
        participant = Participant.create
        participant.person = person
      else
        participant = person.participant
      end

      response_set.responses.each do |r|
        value = OperationalDataExtractor.response_value(r)
        data_export_identifier = r.question.data_export_identifier

        if CHILD_PERSON_NAME_MAP.has_key?(data_export_identifier)
          #person.send("#{CHILD_PERSON_NAME_MAP[data_export_identifier]}=", value)
          person.update_attribute("#{CHILD_PERSON_NAME_MAP[data_export_identifier]}", value)
        end

        if CHILD_PERSON_DATE_OF_BIRTH_MAP.has_key?(data_export_identifier)
          unless value.blank?
            #person.send("#{CHILD_PERSON_DATE_OF_BIRTH_MAP[data_export_identifier]}=", value)
            person.update_attribute("#{CHILD_PERSON_DATE_OF_BIRTH_MAP[data_export_identifier]}", value)
          end
        end
      end
      participant.save!
      person.save!
    end


  end
end

