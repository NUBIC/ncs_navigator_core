class AddCompletionDateToProviderLogistics < ActiveRecord::Migration
  def change
    add_column :provider_logistics, :completion_date, :date
  end
end
