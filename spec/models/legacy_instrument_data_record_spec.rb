# == Schema Information
#
# Table name: legacy_instrument_data_records
#
#  created_at       :datetime
#  id               :integer          not null, primary key
#  instrument_id    :integer          not null
#  mdes_table_name  :string(100)      not null
#  mdes_version     :string(16)       not null
#  parent_record_id :integer
#  psu_id           :integer
#  public_id        :string(36)       not null
#  updated_at       :datetime
#

require 'spec_helper'

describe LegacyInstrumentDataRecord do
  let!(:record) { Factory(:legacy_instrument_data_record) }

  let!(:child_record) { Factory(:legacy_instrument_data_record, :parent_record => record) }

  let!(:value) { Factory(:legacy_instrument_data_value, :legacy_instrument_data_record => record)}

  it 'belongs to an instrument' do
    record.reload.instrument.should be_an(Instrument)
  end

  it 'has values' do
    record.reload.values.should == [value]
  end

  it 'may have children' do
    record.reload.child_records.should == [child_record]
  end

  it 'may have a parent' do
    child_record.reload.parent_record.should == record
  end
end
