class ChangeCraftedItemsTypes < ActiveRecord::Migration
  def self.up
    remove_column :crafted_items, :crafted_item_generated_id
    remove_column :crafted_items, :component_item_id
    add_column :crafted_items, :crafted_item_generated_id, :string
    add_column :crafted_items, :component_item_id, :string
  end

  def self.down
    remove_column :crafted_items, :crafted_item_generated_id
    remove_column :crafted_items, :component_item_id
    add_column :crafted_items, :crafted_item_generated_id, :integer
    add_column :crafted_items, :component_item_id, :integer
  end
end
