class CreatePbsProviderRoles < ActiveRecord::Migration
  def change
    create_table :pbs_provider_roles do |t|

      t.integer :psu_code,                    :null => false
      t.string :provider_role_pbs_id,         :null => false, :limit => 36
      t.references :provider
      t.integer :provider_role_pbs_code,      :null => false
      t.string :provider_role_pbs_other
      t.string :transaction_type,             :limit => 36

      t.timestamps
    end
  end
end
