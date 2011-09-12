class AddTaintToSalesListings < ActiveRecord::Migration
  def self.up
    add_column :sales_listings, :is_tainted, :boolean, :default => false
  end

  def self.down
    remove_column :sales_listings, :is_tainted
  end
end
