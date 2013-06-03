# -*- coding: utf-8 -*-

module OperationalDataExtractor
  class PbsParticipantVerification < Base

    ##
    # If there is an associated child record and
    # a response with the reference identifier 'CHILD_DOB'
    # and that response has a value, update the child record
    # to set the person_dob field to that value.
    #
    # @see OperationalDataExtractor::Base#child
    def extract_data
      if child
        if r = response_set.responses.detect{|r| r.question.reference_identifier == 'CHILD_DOB'}
          if value = response_value(r)
            child.person_dob = value
            child.save!
          end
        end
      end
    end
  end
end