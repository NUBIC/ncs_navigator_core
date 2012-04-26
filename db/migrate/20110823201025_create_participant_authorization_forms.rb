# encoding: utf-8

class CreateParticipantAuthorizationForms < ActiveRecord::Migration
  def self.up
    create_table :participant_authorization_forms do |t|

      t.string :psu_code,               :null => false, :limit => 36
      t.binary :auth_form_id,           :null => false
      t.references :participant
      t.references :contact
      t.references :provider

      t.integer :auth_form_type_code,   :null => false
      t.string :auth_type_other
      t.integer :auth_status_code,      :null => false
      t.string :auth_status_other

      t.string :transaction_type,         :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_authorization_forms
  end
end