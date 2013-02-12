# == Schema Information
# Schema version: 20130212215454
#
# Table name: instrument_contexts
#
#  created_at      :datetime
#  id              :integer          not null, primary key
#  response_set_id :integer          not null
#  updated_at      :datetime
#

class InstrumentContext < ActiveRecord::Base
  belongs_to :response_set, :inverse_of => :instrument_context
  has_many :elements, :class_name => 'InstrumentContextElement'

  default_scope includes(:elements)

  validates_presence_of :response_set_id
end
