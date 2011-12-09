class AddActionNameToParsedAuctions < ActiveRecord::Migration
  def change
    add_column :parsed_auctions, :action_name, :string
  end
end
