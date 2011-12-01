class CreateParsedAuctions < ActiveRecord::Migration
  def change
    create_table :parsed_auctions do |t|
      t.string :item_name
      t.integer :user_id

      t.timestamps
    end
  end
end
