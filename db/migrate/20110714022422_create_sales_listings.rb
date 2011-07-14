class CreateSalesListings < ActiveRecord::Migration
  def self.up
    create_table :sales_listings do |t|
      t.integer :item_id
      t.integer :stacksize
      t.integer :price
      t.integer :undercut_price
      t.integer :deposit_cost
      t.integer :listing_status_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sales_listings
  end
end
