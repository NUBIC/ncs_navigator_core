
ActiveRecord::Schema.define(:version => 0) do
  create_table :foos, :force => true do |t|
    t.string :name
    t.string :uuid
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
end
