class CreatePbsLists < ActiveRecord::Migration

  def self.up
    create_table :pbs_lists do |t|

      t.integer :psu_code,                    :null => false
      t.string :pbs_list_id,                  :null => false, :limit => 36
      t.integer :provider_id
      t.integer :practice_num
      t.integer :in_out_frame_code            #,:null => false
      t.integer :in_sample_code               #,:null => false
      t.integer :substitute_provider_id
      t.integer :in_out_psu_code              #,:null => false
      t.integer :mos
      t.integer :cert_flag_code               #,:null => false
      t.string :stratum
      t.integer :sort_var1
      t.integer :sort_var2
      t.integer :sort_var3
      t.integer :frame_order

      t.decimal :selection_probability_location,  :precision => 7, :scale => 6
      t.decimal :sampling_interval_woman,         :precision => 4, :scale => 2
      t.decimal :selection_probability_woman,     :precision => 7, :scale => 6
      t.decimal :selection_probability_overall,   :precision => 7, :scale => 6

      t.integer :frame_completion_req_code,       :null => false
      t.integer :pr_recruitment_status_code       #,:null => false

      t.date :pr_recruitment_start_date
      t.date :pr_cooperation_date
      t.date :pr_recruitment_end_date

      t.string :transaction_type

      t.timestamps
    end

  end

  def self.down
    drop_table :pbs_lists
  end

end
