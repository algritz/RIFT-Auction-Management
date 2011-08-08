class AddIndexItemIdSalesListings < ActiveRecord::Migration
  def self.up
    add_index :sales_listings, :item_id
    add_index :sales_listings, :listing_status_id
  end

  def self.down
    remove_index :sales_listings, :item_id
    remove_index :sales_listings, :listing_status_id
  end
end
