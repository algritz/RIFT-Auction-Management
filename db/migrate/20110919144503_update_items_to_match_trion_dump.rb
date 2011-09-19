class UpdateItemsToMatchTrionDump < ActiveRecord::Migration
  def self.up
    add_column :items, :icon, :string
    add_column :items, :soulboundtrigger, :string
    add_column :items, :riftgem, :string
    add_column :items, :salvageskill, :string
    add_column :items, :salvageskilllevel, :integer
    add_column :items, :runebreakskilllevel, :integer
    add_column :items, :isAugmented, :boolean
    add_index :items, :soulboundtrigger
  end

  def self.down
    remove_column :items, :icon
    remove_column :items, :soulboundtrigger
    remove_column :items, :riftgem
    remove_column :items, :salvageskill
    remove_column :items, :salvageskilllevel
    remove_column :items, :runebreakskilllevel
    remove_column :items, :isAugmented
    remove_index :items, :soulboundtrigger
  end
end
