# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110730184014) do

  create_table "competitor_styles", :force => true do |t|
    t.string    "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "competitors", :force => true do |t|
    t.string    "name"
    t.integer   "competitor_style_id"
    t.integer   "source_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "crafted_items", :force => true do |t|
    t.integer   "crafted_item_generated_id"
    t.integer   "crafted_item_stacksize"
    t.integer   "component_item_id"
    t.integer   "component_item_quantity"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string    "description"
    t.integer   "vendor_selling_price"
    t.integer   "vendor_buying_price"
    t.integer   "source_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_crafted"
    t.boolean   "to_list"
    t.integer   "item_level"
  end

  add_index "items", ["id"], :name => "index_items_on_id"

  create_table "listing_statuses", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "sales_listings", :force => true do |t|
    t.integer   "item_id"
    t.integer   "stacksize"
    t.integer   "price"
    t.integer   "deposit_cost"
    t.integer   "listing_status_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_undercut_price"
    t.boolean   "relisted_status",   :default => false
  end

  add_index "sales_listings", ["id"], :name => "index_sales_listings_on_id"

  create_table "sources", :force => true do |t|
    t.string    "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

end
