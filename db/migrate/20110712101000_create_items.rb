class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :description
      t.integer :vendor_selling_price
      t.integer :vendor_buying_price
      t.integer :source_id

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
