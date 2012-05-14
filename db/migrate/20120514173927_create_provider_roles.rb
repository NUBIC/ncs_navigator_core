class CreateProviderRoles < ActiveRecord::Migration
  def self.up
    create_table :provider_roles do |t|

      t.integer :psu_code,                    :null => false
      t.string :provider_role_id,             :null => false, :limit => 36
      t.references :provider
      t.integer :provider_ncs_role_code,      :null => false
      t.string :provider_ncs_role_other
      t.string :transaction_type,             :limit => 36

      t.timestamps
    end
  end
  
  def self.down
    drop_table :provider_roles
  end
end
