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

  def set(key, value)
    elements.build(:key => key, :value => value)
  end

  def to_mustache
    FakeMustache.new(self)
  end

  class FakeMustache < ::Mustache
    def initialize(ctx)
      ctx.elements.each { |e| self[e.key] = e.value }
    end
  end
end
