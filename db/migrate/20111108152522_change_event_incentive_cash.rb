class ChangeEventIncentiveCash < ActiveRecord::Migration
  def change
    change_column :events, :event_incentive_cash, :decimal, :precision => 12, :scale => 2
  end
end
