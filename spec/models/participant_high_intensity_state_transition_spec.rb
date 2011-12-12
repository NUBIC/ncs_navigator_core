# == Schema Information
# Schema version: 20111212224350
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

require 'spec_helper'

describe ParticipantHighIntensityStateTransition do
  pending "add some examples to (or delete) #{__FILE__}"
end
