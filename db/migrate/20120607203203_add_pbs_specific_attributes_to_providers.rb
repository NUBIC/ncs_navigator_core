class AddPbsSpecificAttributesToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :name_practice,            :string, :limit => 100
    add_column :providers, :list_subsampling_code,    :integer
    add_column :providers, :proportion_weeks_sampled, :integer
    add_column :providers, :proportion_days_sampled,  :integer
    add_column :providers, :sampling_notes,           :string, :limit => 1000
  end
end