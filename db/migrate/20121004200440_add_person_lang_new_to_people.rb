class AddPersonLangNewToPeople < ActiveRecord::Migration
  def change
    add_column :people, :language_new_code, :integer
    add_column :people, :language_new_other, :string
  end
end
