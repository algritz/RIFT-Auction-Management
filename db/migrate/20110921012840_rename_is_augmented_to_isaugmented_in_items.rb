class RenameIsAugmentedToIsaugmentedInItems < ActiveRecord::Migration
   def self.up
    rename_column(:items, :isAugmented, :isaugmented)
  end

  def self.down
    rename_column(:items, :isaugmented, :isAugmented)
  end
end
