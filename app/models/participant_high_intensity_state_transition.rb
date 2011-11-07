# == Schema Information
# Schema version: 20111018175121
#
# Table name: participant_high_intensity_state_transitions
#
#  id             :integer         not null, primary key
#  participant_id :integer
#  event          :string(255)
#  from           :string(255)
#  to             :string(255)
#  created_at     :datetime
#

class ParticipantHighIntensityStateTransition < ActiveRecord::Base
  belongs_to :participant
end
