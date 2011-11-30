class AddSalesListingIdToParsedAuctions < ActiveRecord::Migration
  def up
    add_column :parsed_auctions, :sales_listing_id, :integer
  end

  def down
    remove_column  :parsed_auctions, :sales_listing_id
  end
end
