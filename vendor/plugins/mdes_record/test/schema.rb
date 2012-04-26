# -*- coding: utf-8 -*-


ActiveRecord::Schema.define(:version => 0) do
  create_table :foos, :force => true do |t|
    t.string :name
    t.string :uuid
    t.integer :psu_code
  end

  create_table :bars, :force => true do |t|
    t.string :name
    t.string :bar_id
  end

  create_table :date_foos, :force => true do |t|
    t.string :name
    t.string :uuid
    t.date :start_date_date
    t.string :start_date
  end

  create_table :ncs_codes, :force => true do |t|
    t.string   :list_name
    t.string   :list_description
    t.string   :display_text
    t.integer  :local_code
    t.string   :global_code
  end
end