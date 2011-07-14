class ChangeUndercutPriceToBoolean < ActiveRecord::Migration
  def self.up
    remove_column  :sales_listings, :undercut_price
    add_column :sales_listings, :is_undercut_price, :boolean
  end

  def self.down
    remove_column :sales_listings, :is_undercut_price
    add_column  :sales_listings, :undercut_price, :integer
  end
end
