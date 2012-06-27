# == Schema Information
# Schema version: 20120626221317
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

# -*- coding: utf-8 -*-

class ParticipantHighIntensityStateTransition < ActiveRecord::Base
  belongs_to :participant
end
