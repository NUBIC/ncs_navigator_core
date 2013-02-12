# == Schema Information
# Schema version: 20130212215454
#
# Table name: instrument_context_elements
#
#  created_at            :datetime
#  id                    :integer          not null, primary key
#  instrument_context_id :integer          not null
#  key                   :string(255)
#  updated_at            :datetime
#  value                 :text
#

require 'spec_helper'

describe InstrumentContextElement do
  pending "add some examples to (or delete) #{__FILE__}"
end
