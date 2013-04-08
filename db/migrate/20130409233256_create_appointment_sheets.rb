class CreateAppointmentSheets < ActiveRecord::Migration
  def change
    create_table :appointment_sheets do |t|

      t.timestamps
    end
  end
end
