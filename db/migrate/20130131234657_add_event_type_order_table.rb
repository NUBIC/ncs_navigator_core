class AddEventTypeOrderTable < ActiveRecord::Migration
  def up
    create_table :event_type_order do |t|
      t.integer :event_type_code, :null => false
    end
  end

  def down
    drop_table :event_type_order
  end
end
