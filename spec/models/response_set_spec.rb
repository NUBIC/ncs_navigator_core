# == Schema Information
# Schema version: 20110805151543
#
# Table name: response_sets
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  survey_id    :integer
#  access_code  :string(255)
#  started_at   :datetime
#  completed_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe ResponseSet do
  
  it { should belong_to(:person) }
  it { should belong_to(:contact_link) }
  
end
