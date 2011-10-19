class RemoveSomeIndexesOnSalesListing < ActiveRecord::Migration
  def self.up
    remove_index :sales_listings, :is_undercut_price
    remove_index :sales_listings, :is_tainted
  end

  def self.down
    add_index :sales_listings, :is_undercut_price
    add_index :sales_listings, :is_tainted
  end
end
