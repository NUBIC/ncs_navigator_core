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

class LegacyInstrumentDataValue < ActiveRecord::Base
  belongs_to :legacy_instrument_data_record, :inverse_of => :values
end
