# == Schema Information
# Schema version: 20120321181032
#
# Table name: fieldworks
#
#  fieldwork_id  :string(36)      primary key
#  received_data :binary
#  created_at    :datetime
#  updated_at    :datetime
#  client_id     :string(255)
#  end_date      :date
#  start_date    :date
#  original_data :binary
#

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

  ##
  # Retrieves a fieldwork set by ID.  If no fieldwork set by that ID can be
  # found, initializes an empty set, saves it, and returns that set.
  #
  # This method therefore has the ability to violate the presence validations
  # listed above.  This privilege is intentional: we want to be able to save
  # datasets from field clients even if they give us a fieldwork ID that we
  # know nothing about, but we also want to encode the idea that we _usually_
  # expect a date range and client ID.
  def self.for(id)
    find_or_initialize_by_fieldwork_id(id).tap do |r|
      r.save!(:validate => false) if r.new_record?
    end
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
