class CreateNonInterviewProviders < ActiveRecord::Migration
  def change
    create_table :non_interview_providers do |t|

      t.integer :psu_code,                    :null => false
      t.string :non_interview_provider_id,    :null => false, :limit => 36
      t.references :contact
      t.references :provider
      t.integer :nir_type_provider_code,      :null => false
      t.string :nir_type_provider_other
      t.integer :nir_closed_info_code,        :null => false
      t.string :nir_closed_info_other
      t.date :when_closure
      t.integer :perm_closure_code,           :null => false
      t.integer :who_refused_code,            :null => false
      t.string :who_refused_other
      t.integer :refuser_strength_code,       :null => false
      t.integer :ref_action_provider_code,    :null => false
      t.integer :who_confirm_noprenatal_code, :null => false
      t.string :who_confirm_noprenatal_other
      t.integer :nir_moved_info_code,         :null => false
      t.string :nir_moved_info_other
      t.date :when_moved
      t.integer :perm_moved_code,             :null => false
      t.text :nir_pbs_comment

      t.string :transaction_type

      t.timestamps
    end
  end
end
