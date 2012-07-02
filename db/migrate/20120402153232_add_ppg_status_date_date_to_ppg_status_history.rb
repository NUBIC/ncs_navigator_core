

class AddPpgStatusDateDateToPpgStatusHistory < ActiveRecord::Migration
  def change
    add_column :ppg_status_histories, :ppg_status_date_date, :date
  end
end