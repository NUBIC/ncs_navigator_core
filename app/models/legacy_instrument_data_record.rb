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

class LegacyInstrumentDataRecord < ActiveRecord::Base
  belongs_to :instrument, :inverse_of => :legacy_instrument_data_records
  has_many :values, :class_name => 'LegacyInstrumentDataValue',
    :inverse_of => :legacy_instrument_data_record

  belongs_to :parent_record, :class_name => self.name,
    :inverse_of => :child_records
  has_many :child_records, :class_name => self.name,
    :inverse_of => :parent_record, :foreign_key => :parent_record_id
end
