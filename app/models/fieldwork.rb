require 'uuid'

class Fieldwork < ActiveRecord::Base
  set_primary_key :fieldwork_id

  before_create :set_default_id

  def self.for(id)
    find_or_create_by_fieldwork_id(id)
  end

  def set_default_id
    self.fieldwork_id ||= UUID.generate
  end
end
