# -*- coding: utf-8 -*-
class AddProviderInstituteToTelephones < ActiveRecord::Migration
  def change
    add_column :telephones, :provider_id, :integer
    add_column :telephones, :institute_id, :integer
  end
end