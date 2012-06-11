class CreatePersonnelProviderLinkTable < ActiveRecord::Migration
  def self.up
    create_table :personnel_provider_links do |t|
      t.references :provider
      t.references :person
      t.boolean :primary_contact
      t.timestamps
    end
  end

  def self.down
    drop_table :personnel_provider_links
  end
end