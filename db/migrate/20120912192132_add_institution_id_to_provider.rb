class AddInstitutionIdToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :institution_id, :integer
    add_column :addresses, :institute_id, :integer
  end
end
