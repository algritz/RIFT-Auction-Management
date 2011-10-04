class RemoveIndexOnDateForSaleslistings < ActiveRecord::Migration
  def self.up
    remove_index :sales_listings, :updated_at
  end

  def self.down
    add_index :sales_listings, :updated_at
  end
end
