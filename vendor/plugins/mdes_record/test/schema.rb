
ActiveRecord::Schema.define(:version => 0) do
  create_table :foos, :force => true do |t|
    t.string :name
    t.binary :uuid
  end
  create_table :bars, :force => true do |t|
    t.string :name
    t.binary :bar_id
  end
  create_table :date_foos, :force => true do |t|
    t.string :name
    t.binary :uuid
    t.date :start_date
    t.string :start
  end
end