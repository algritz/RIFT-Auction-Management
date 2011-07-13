class RenameIsCraftedToIsCrafted < ActiveRecord::Migration
  def self.up
    rename_column :items, :isCrafted, :is_crafted 
  end

  def self.down
    rename_column :items, :is_crafted, :isCrafted 
  end
end
