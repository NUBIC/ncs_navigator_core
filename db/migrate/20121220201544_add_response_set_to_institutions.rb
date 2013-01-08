class AddResponseSetToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions,  :response_set_id, :integer
  end
end
