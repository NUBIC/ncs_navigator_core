# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PbsParticipantVerification < Base

    def extract_data
      child_dob_reference_identifier = 'CHILD_DOB'
      if child
        r = response_set.responses.detect{|r| r.question.reference_identifier == child_dob_reference_identifier}
        value = response_value(r)
        child.person_dob = value
        child.save!
      end
    end
  end
end