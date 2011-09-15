class PrepareItemsToRiftItemDbMigration < ActiveRecord::Migration
  def self.up
    add_column :items, :itemKey, :string
    add_column :items, :rarity, :string
    add_index :items, :itemKey
    add_index :items, :rarity
  end

  def self.down
    remove_column :items, :rarity
    remove_column :items, :itemKey
    remove_index :items, :itemKey
    remove_index :items, :rarity
  end
end
