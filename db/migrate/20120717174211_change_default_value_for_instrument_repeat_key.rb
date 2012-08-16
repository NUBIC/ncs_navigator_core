class ChangeDefaultValueForInstrumentRepeatKey < ActiveRecord::Migration

  def up
    change_table :instruments do |t|
      t.change(:instrument_repeat_key, :integer, :null => false, :default => 0)
    end
  end

  def down
    # NOOP
  end

end
