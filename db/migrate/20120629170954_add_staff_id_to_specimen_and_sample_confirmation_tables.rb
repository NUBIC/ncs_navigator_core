class AddStaffIdToSpecimenAndSampleConfirmationTables < ActiveRecord::Migration
  def up  
    add_column :sample_receipt_confirmations, :staff_id, :string, :limit => 36
    execute("UPDATE sample_receipt_confirmations SET staff_id='unknown'")
    change_column :sample_receipt_confirmations, :staff_id, :string, :null => false
    
    add_column :specimen_receipt_confirmations, :staff_id, :string, :limit => 36
    execute("UPDATE specimen_receipt_confirmations SET staff_id='unknown'")
    change_column :specimen_receipt_confirmations, :staff_id, :string, :null => false
  end
  def down
    remove_column :sample_receipt_confirmations, :staff_id
    remove_column :specimen_receipt_confirmations, :staff_id
  end
end
