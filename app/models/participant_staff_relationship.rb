# == Schema Information
# Schema version: 20120607203203
#
# Table name: participant_staff_relationships
#
#  id             :integer         not null, primary key
#  participant_id :integer
#  staff_id       :string(255)
#  primary        :boolean
#

# -*- coding: utf-8 -*-

class ParticipantStaffRelationship < ActiveRecord::Base

  belongs_to :participant

end
