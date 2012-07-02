# -*- coding: utf-8 -*-


class AddIndexOnTimestampsToPpgStatusHistory < ActiveRecord::Migration
  def change
    add_index :ppg_status_histories, :created_at
    add_index :ppg_status_histories, :updated_at
  end
end