class SetPscIdealDateOnEvents < ActiveRecord::Migration
  def up
    Event.all.each do |e|
      e.update_attribute(:psc_ideal_date, e.event_start_date) if e.psc_ideal_date.blank?
    end
  end

  def down
    # NOOP - there should be no reason to delete the psc_ideal_date value
  end
end
