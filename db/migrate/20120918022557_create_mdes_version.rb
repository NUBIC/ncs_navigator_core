class CreateMdesVersion < ActiveRecord::Migration
  def change
    create_table :mdes_version, :id => false do |t|
      t.string :number, :limit => 10, :null => false
    end
  end
end
