# -*- coding: utf-8 -*-
# == Schema Information
# Schema version: 20120629204215
#
# Table name: participant_staff_relationships
#
#  id             :integer          not null, primary key
#  participant_id :integer
#  primary        :boolean
#  staff_id       :string(255)
#



class ParticipantStaffRelationship < ActiveRecord::Base

  belongs_to :participant

end

