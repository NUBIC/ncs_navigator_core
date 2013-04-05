class AddIneligibilityBatchIdentifierToPersonProviderLink < ActiveRecord::Migration
  def up
    add_column :person_provider_links, :ineligibility_batch_identifier, :string, :limit => 36
  end

  def down
    remove_column :person_provider_links, :ineligibility_batch_identifier
  end
end
