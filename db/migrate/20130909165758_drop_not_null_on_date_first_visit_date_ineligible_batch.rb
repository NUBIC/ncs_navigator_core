class DropNotNullOnDateFirstVisitDateIneligibleBatch < ActiveRecord::Migration
  def up
    change_column :ineligible_batches, :date_first_visit_date, :date, :null => true
  end

  def down
    change_column :ineligible_batches, :date_first_visit_date, :date, :null => false
  end
end
