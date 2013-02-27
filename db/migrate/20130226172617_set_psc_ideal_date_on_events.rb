class SetPscIdealDateOnEvents < ActiveRecord::Migration
  def up
    execute("UPDATE events SET psc_ideal_date = event_start_date")
  end

  def down
    # NOOP - there should be no reason to delete the psc_ideal_date value
  end
end
