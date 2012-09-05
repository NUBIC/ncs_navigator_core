# == Schema Information
#
# Table name: legacy_instrument_data_values
#
#  created_at                       :datetime
#  id                               :integer          not null, primary key
#  legacy_instrument_data_record_id :integer          not null
#  mdes_variable_name               :string(50)       not null
#  updated_at                       :datetime
#  value                            :text
#

require 'spec_helper'

describe LegacyInstrumentDataValue do
  let(:record) { Factory(:legacy_instrument_data_value) }

  it 'belongs to an instrument' do
    record.legacy_instrument_data_record.should be_a(LegacyInstrumentDataRecord)
  end
end
