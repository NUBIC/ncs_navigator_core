
ActiveRecord::Schema.define(:version => 0) do
  create_table :foos, :force => true do |t|
    t.string :name
    t.binary :uuid
  end
  create_table :bars, :force => true do |t|
    t.string :name
    t.binary :bar_id
  end
end