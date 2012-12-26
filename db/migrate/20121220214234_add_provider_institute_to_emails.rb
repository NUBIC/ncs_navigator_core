class AddProviderInstituteToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :provider_id, :integer
    add_column :emails, :institute_id, :integer
  end
end
