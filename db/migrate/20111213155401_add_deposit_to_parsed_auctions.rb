class AddDepositToParsedAuctions < ActiveRecord::Migration
  def change
    add_column :parsed_auctions, :deposit, :integer
  end
end
