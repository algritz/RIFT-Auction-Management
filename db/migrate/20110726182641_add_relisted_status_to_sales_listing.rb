class AddRelistedStatusToSalesListing < ActiveRecord::Migration
  def self.up
    add_column :sales_listings, :relisted_status, :boolean, :default => false
    
  end

  def self.down
    remove_column :sales_listings, :relisted_status
  end
end
