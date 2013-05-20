class AddSsuTsuToParticipant < ActiveRecord::Migration
  def change
    add_column :participants, :ssu, :string
    add_column :participants, :tsu, :string
  end
end
