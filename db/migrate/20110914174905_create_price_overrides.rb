class CreatePriceOverrides < ActiveRecord::Migration
  def self.up
    create_table :price_overrides do |t|
      t.integer :item_id
      t.integer :user_id
      t.integer :price_per

      t.timestamps
    end
  end

  def self.down
    drop_table :price_overrides
  end
end
