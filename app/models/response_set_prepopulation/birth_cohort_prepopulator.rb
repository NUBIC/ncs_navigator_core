require 'ncs_navigator/core'
module ResponseSetPrepopulation
  module BirthCohortPrepopulator
    def is_p_type_15?(question, participant)
      if participant.p_type.local_code == 15
        answer_for(question, true)
      elsif participant.child_participant? && participant.mother.try(:participant) && participant.mother.participant.p_type.local_code == 15
        answer_for(question, true)
      else
        answer_for(question, false)
      end
    end
  end
end