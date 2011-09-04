class AddCraftingAllowedToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :crafting_allowed, :boolean
  end

  def self.down
    remove_column :sources, :crafting_allowed
  end
end
