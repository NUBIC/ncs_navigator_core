class EnsureOrderedEventTypeCodesAreUnique < ActiveRecord::Migration
  def up
    add_index :event_type_order, :event_type_code, :unique => true
  end

  def down
    remove_index :event_type_order, :column => :event_type_code
  end
end
