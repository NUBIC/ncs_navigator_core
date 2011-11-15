class RemoveDwellingUnitConstraintOnAddress < ActiveRecord::Migration
  def up
    change_column :addresses, :dwelling_unit_id, :integer, :null => true
  end
  
  def down
    # NOOP
  end
end
