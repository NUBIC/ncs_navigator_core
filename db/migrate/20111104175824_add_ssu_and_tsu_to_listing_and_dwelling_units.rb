class AddSsuAndTsuToListingAndDwellingUnits < ActiveRecord::Migration
  def change
    add_column :listing_units, :ssu_id, :string
    add_column :listing_units, :tsu_id, :string
    add_column :dwelling_units, :ssu_id, :string
    add_column :dwelling_units, :tsu_id, :string
  end
end