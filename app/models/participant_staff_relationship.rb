# -*- coding: utf-8 -*-

# == Schema Information
# Schema version: 20120426034324
#
# Table name: participant_staff_relationships
#
#  id             :integer         not null, primary key
#  participant_id :integer
#  staff_id       :string(255)
#  primary        :boolean
#

class ParticipantStaffRelationship < ActiveRecord::Base

  belongs_to :participant

end
