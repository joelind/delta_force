ActiveRecord::Schema.define do

  create_table "bars", :force => true

  create_table "foos", :force => true do |t|
    t.integer  "bar_id"
    t.float    "x"
    t.float    "y"
    t.float    "z"
    t.date     "period"
  end
end
