class RemoveDwellingUnitConstraintOnAddress < ActiveRecord::Migration
  def change
    change_column :addresses, :dwelling_unit_id, :integer, :null => true
  end
end
