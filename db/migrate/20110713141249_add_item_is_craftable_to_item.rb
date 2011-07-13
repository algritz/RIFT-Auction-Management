class AddItemIsCraftableToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :isCrafted, :boolean
    add_index :items, :id
  end

  def self.down
    remove_column :items, :isCrafted
    remove_index :items, :id
  end
end
