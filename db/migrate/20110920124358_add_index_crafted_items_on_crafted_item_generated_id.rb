class AddIndexCraftedItemsOnCraftedItemGeneratedId < ActiveRecord::Migration
  def self.up
    add_index :crafted_items, :crafted_item_generated_id
    add_index :crafted_items, :component_item_id
    add_index :crafted_items, :name
  end

  def self.down
    remove_index :crafted_items, :crafted_item_generated_id
    remove_index :crafted_items, :component_item_id
    remove_index :crafted_items, :name
  end
end
