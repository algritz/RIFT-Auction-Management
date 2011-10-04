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

ActiveRecord::Schema.define(:version => 20111004140812) do

  create_table "competitor_styles", :force => true do |t|
    t.string    "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "competitor_styles", ["description"], :name => "index_competitor_styles_on_description"
  add_index "competitor_styles", ["id"], :name => "index_competitor_styles_on_id"

  create_table "competitors", :force => true do |t|
    t.string    "name"
    t.integer   "competitor_style_id"
    t.integer   "source_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "user_id"
  end

  add_index "competitors", ["competitor_style_id"], :name => "index_competitors_on_competitor_style_id"
  add_index "competitors", ["id"], :name => "index_competitors_on_id"
  add_index "competitors", ["source_id"], :name => "index_competitors_on_source_id"
  add_index "competitors", ["user_id"], :name => "index_competitors_on_user_id"

  create_table "crafted_items", :force => true do |t|
    t.integer   "crafted_item_stacksize"
    t.integer   "component_item_quantity"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "required_skill"
    t.integer   "required_skill_point"
    t.integer   "rift_id"
    t.string    "name"
    t.string    "crafted_item_generated_id"
    t.string    "component_item_id"
  end

  add_index "crafted_items", ["component_item_id"], :name => "index_crafted_items_on_component_item_id"
  add_index "crafted_items", ["crafted_item_generated_id"], :name => "index_crafted_items_on_crafted_item_generated_id"
  add_index "crafted_items", ["id"], :name => "index_crafted_items_on_id"
  add_index "crafted_items", ["name"], :name => "index_crafted_items_on_name"
  add_index "crafted_items", ["required_skill"], :name => "index_crafted_items_on_required_skill"
  add_index "crafted_items", ["required_skill_point"], :name => "index_crafted_items_on_required_skill_point"

  create_table "creation_codes", :force => true do |t|
    t.string    "creation_code"
    t.boolean   "used"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "creation_codes", ["creation_code"], :name => "index_creation_codes_on_creation_code"
  add_index "creation_codes", ["id"], :name => "index_creation_codes_on_id"
  add_index "creation_codes", ["used"], :name => "index_creation_codes_on_used"

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
    t.string    "note"
    t.string    "itemkey"
    t.string    "rarity"
    t.string    "icon"
    t.string    "soulboundtrigger"
    t.string    "riftgem"
    t.string    "salvageskill"
    t.integer   "salvageskilllevel"
    t.integer   "runebreakskilllevel"
    t.boolean   "isaugmented"
  end

  add_index "items", ["description"], :name => "index_items_on_description"
  add_index "items", ["id"], :name => "index_items_on_id"
  add_index "items", ["is_crafted"], :name => "index_items_on_is_crafted"
  add_index "items", ["isaugmented"], :name => "index_items_on_isaugmented"
  add_index "items", ["item_level"], :name => "index_items_on_item_level"
  add_index "items", ["itemkey"], :name => "index_items_on_itemKey"
  add_index "items", ["rarity"], :name => "index_items_on_rarity"
  add_index "items", ["soulboundtrigger"], :name => "index_items_on_soulboundtrigger"
  add_index "items", ["source_id"], :name => "index_items_on_source_id"
  add_index "items", ["to_list"], :name => "index_items_on_to_list"

  create_table "listing_statuses", :force => true do |t|
    t.string    "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "position"
    t.boolean   "is_final",    :default => false
  end

  add_index "listing_statuses", ["description"], :name => "index_listing_statuses_on_description"
  add_index "listing_statuses", ["id"], :name => "index_listing_statuses_on_id"
  add_index "listing_statuses", ["is_final"], :name => "index_listing_statuses_on_is_final"

  create_table "price_overrides", :force => true do |t|
    t.integer   "item_id"
    t.integer   "user_id"
    t.integer   "price_per"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "price_overrides", ["id"], :name => "index_price_overrides_on_id"
  add_index "price_overrides", ["item_id"], :name => "index_price_overrides_on_item_id"
  add_index "price_overrides", ["user_id"], :name => "index_price_overrides_on_user_id"

  create_table "sales_listings", :force => true do |t|
    t.integer   "item_id"
    t.integer   "stacksize"
    t.integer   "price"
    t.integer   "deposit_cost"
    t.integer   "listing_status_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_undercut_price", :default => false
    t.boolean   "relisted_status",   :default => false
    t.integer   "user_id"
    t.integer   "profit"
    t.boolean   "is_tainted",        :default => false
  end

  add_index "sales_listings", ["id"], :name => "index_sales_listings_on_id"
  add_index "sales_listings", ["is_tainted"], :name => "index_sales_listings_on_is_tainted"
  add_index "sales_listings", ["is_undercut_price"], :name => "index_sales_listings_on_is_undercut_price"
  add_index "sales_listings", ["item_id"], :name => "index_sales_listings_on_item_id"
  add_index "sales_listings", ["listing_status_id"], :name => "index_sales_listings_on_listing_status_id"
  add_index "sales_listings", ["user_id"], :name => "index_sales_listings_on_user_id"

  create_table "sources", :force => true do |t|
    t.string    "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "crafting_allowed"
  end

  add_index "sources", ["crafting_allowed"], :name => "index_sources_on_crafting_allowed"
  add_index "sources", ["description"], :name => "index_sources_on_description"
  add_index "sources", ["id"], :name => "index_sources_on_id"

  create_table "toon_skill_levels", :force => true do |t|
    t.integer   "toon_id"
    t.integer   "source_id"
    t.integer   "skill_level"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "toon_skill_levels", ["id"], :name => "index_toon_skill_levels_on_id"
  add_index "toon_skill_levels", ["skill_level"], :name => "index_toon_skill_levels_on_skill_level"
  add_index "toon_skill_levels", ["source_id"], :name => "index_toon_skill_levels_on_source_id"
  add_index "toon_skill_levels", ["toon_id"], :name => "index_toon_skill_levels_on_toon_id"

  create_table "toons", :force => true do |t|
    t.string    "name"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "toons", ["id"], :name => "index_toons_on_id"
  add_index "toons", ["name"], :name => "index_toons_on_name"
  add_index "toons", ["user_id"], :name => "index_toons_on_user_id"

  create_table "users", :force => true do |t|
    t.string    "name"
    t.string    "email"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "encrypted_password"
    t.string    "salt"
    t.boolean   "is_admin"
    t.string    "creation_code"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["is_admin"], :name => "index_users_on_is_admin"

  create_table "wanted_items", :force => true do |t|
    t.integer   "item_id"
    t.integer   "toon_id"
    t.boolean   "is_public"
    t.integer   "price_per"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "wanted_items", ["id"], :name => "index_wanted_items_on_id"
  add_index "wanted_items", ["is_public"], :name => "index_wanted_items_on_is_public"
  add_index "wanted_items", ["item_id"], :name => "index_wanted_items_on_item_id"
  add_index "wanted_items", ["toon_id"], :name => "index_wanted_items_on_toon_id"

end
