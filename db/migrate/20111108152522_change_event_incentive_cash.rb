# -*- coding: utf-8 -*-

class ChangeEventIncentiveCash < ActiveRecord::Migration
  def up
    change_column :events, :event_incentive_cash, :decimal, :precision => 12, :scale => 2
  end

  def down
    # NOOP
  end
end