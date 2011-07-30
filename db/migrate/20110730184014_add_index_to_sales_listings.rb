class AddIndexToSalesListings < ActiveRecord::Migration
  def self.up
    add_index :sales_listings, :id
  end

  def self.down
     remove_index :sales_listings, :id
  end
end
