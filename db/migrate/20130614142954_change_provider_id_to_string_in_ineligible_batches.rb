class ChangeProviderIdToStringInIneligibleBatches < ActiveRecord::Migration
  def up
    change_column :ineligible_batches, :provider_id, :string, :limit => 36
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
