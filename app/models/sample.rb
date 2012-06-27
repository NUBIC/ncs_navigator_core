# == Schema Information
# Schema version: 20120626221317
#
# Table name: samples
#
#  id            :integer         not null, primary key
#  sample_id     :string(36)      not null
#  instrument_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Sample < ActiveRecord::Base
  belongs_to :instrument
  
  validates_presence_of :sample_id
  validates_presence_of :instrument_id
  
end
