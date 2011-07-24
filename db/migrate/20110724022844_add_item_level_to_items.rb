class AddItemLevelToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :item_level, :integer
  end

  def self.down
    remove_column :items, :item_level
  end
end
