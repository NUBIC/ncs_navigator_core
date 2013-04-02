require 'ncs_navigator/core'
module ResponseSetPrepopulation
  module BirthCohortPrepopulator
    def is_participant_p_type_15?(question, participant)
      answer_for(question, participant.p_type.local_code == 15 ? true : false)
    end
  end
end