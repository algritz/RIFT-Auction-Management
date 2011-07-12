class CreateCraftedItems < ActiveRecord::Migration
  def self.up
    create_table :crafted_items do |t|
      t.integer :crafted_item_generated_id
      t.integer :crafted_item_stacksize
      t.integer :component_item_id
      t.integer :component_item_quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :crafted_items
  end
end
