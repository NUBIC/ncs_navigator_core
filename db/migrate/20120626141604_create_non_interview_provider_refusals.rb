# -*- coding: utf-8 -*-
class CreateNonInterviewProviderRefusals < ActiveRecord::Migration
  def change
    create_table :non_interview_provider_refusals do |t|
      t.integer :psu_code,                    :null => false
      t.string :nir_provider_refusal_id,      :null => false, :limit => 36
      t.references :non_interview_provider

      t.integer :refusal_reason_pbs_code,     :null => false
      t.string :refusal_reason_pbs_other

      t.string :transaction_type

      t.timestamps
    end
  end
end
