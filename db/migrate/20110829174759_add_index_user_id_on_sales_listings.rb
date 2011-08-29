class AddIndexUserIdOnSalesListings < ActiveRecord::Migration
  def self.up
     add_index :sales_listings, :user_id
  end

  def self.down
    remove_index :sales_listings, :user_id
  end
end
