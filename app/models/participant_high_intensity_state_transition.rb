# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: participant_high_intensity_state_transitions
#
#  created_at     :datetime
#  event          :string(255)
#  from           :string(255)
#  id             :integer          not null, primary key
#  participant_id :integer
#  to             :string(255)
#



class ParticipantHighIntensityStateTransition < ActiveRecord::Base
  belongs_to :participant
end

