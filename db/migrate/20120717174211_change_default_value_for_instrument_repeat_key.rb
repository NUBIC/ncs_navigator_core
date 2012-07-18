class ChangeDefaultValueForInstrumentRepeatKey < ActiveRecord::Migration

  def change
    change_table :instruments do |t|
      t.change(:instrument_repeat_key, :integer, :null => false, :default => 0)
    end
  end

end
