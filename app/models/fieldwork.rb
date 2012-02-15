require 'uuid'

class Fieldwork < ActiveRecord::Base
  set_primary_key :fieldwork_id

  before_create :set_default_id

  attr_accessible :client_id
  attr_accessible :end_date
  attr_accessible :start_date

  validates_presence_of :client_id
  validates_presence_of :end_date
  validates_presence_of :start_date

  def self.for(id)
    find_or_create_by_fieldwork_id(id)
  end

  def set_default_id
    self.fieldwork_id ||= UUID.generate
  end

  def as_json(options = nil)
    if received_data
      JSON.parse(received_data)
    else
      { 'contacts' => [], 'participants' => [] }
    end
  end
end
