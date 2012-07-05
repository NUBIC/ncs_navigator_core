# -*- coding: utf-8 -*-
class ImproveNcsCode < ActiveRecord::Migration
  def up
    remove_column :ncs_codes, :global_code
    remove_column :ncs_codes, :list_description

    add_index :ncs_codes, :local_code, :unique => false, :name => 'idx_ncs_codes_code'
    add_index :ncs_codes, :list_name, :unique => false, :name => 'idx_ncs_codes_list'
    add_index :ncs_codes, [:local_code, :list_name], :unique => true,
      :name => 'un_ncs_codes_code_and_list'
  end

  def down
    %w(idx_ncs_codes_code idx_ncs_codes_list un_ncs_codes_code_and_list).each do |name|
      remove_index :ncs_codes, :name => name
    end

    add_column :ncs_codes, :list_description, :string
    add_column :ncs_codes, :global_code, :string
  end
end
