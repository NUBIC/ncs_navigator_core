class AddPbsAttributesToPersonProviderLink < ActiveRecord::Migration
  def change
    add_column :person_provider_links, :sampled_person_code,        :integer, :null => false
    add_column :person_provider_links, :pre_screening_status_code,  :integer, :null => false
    add_column :person_provider_links, :date_first_visit,           :string
    add_column :person_provider_links, :date_first_visit_date,      :date
  end
end
