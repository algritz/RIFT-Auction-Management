class AddProfitToSalesListing < ActiveRecord::Migration
  def self.up
    add_column :sales_listings, :profit, :integer
  end

  def self.down
    remove_column :sales_listings, :profit
  end
end
