class AddDefaultValueToSalesListings < ActiveRecord::Migration
  def self.up
     change_column :sales_listings, :is_undercut_price, :boolean, :default => false
  end

  def self.down
    change_column :sales_listings, :is_undercut_price, :boolean, :default => nil
  end
end
