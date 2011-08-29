class AddUserIdToSalesListings < ActiveRecord::Migration
  def self.up
    add_column :sales_listings, :user_id, :integer
  end

  def self.down
    remove_column :sales_listings, :user_id
  end
end
