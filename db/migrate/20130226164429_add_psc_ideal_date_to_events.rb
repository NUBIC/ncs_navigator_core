class AddPscIdealDateToEvents < ActiveRecord::Migration
  def up
    add_column :events, :psc_ideal_date, :date
  end

  def down
    remove_column :events, :psc_ideal_date
  end
end
