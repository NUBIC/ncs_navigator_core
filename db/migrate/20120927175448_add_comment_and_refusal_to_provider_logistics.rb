class AddCommentAndRefusalToProviderLogistics < ActiveRecord::Migration
  def change
    add_column :provider_logistics, :comment, :text
    add_column :provider_logistics, :refusal, :boolean
  end
end
