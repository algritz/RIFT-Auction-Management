class RenameItemKeyToItemkeyInItems < ActiveRecord::Migration
  def self.up
    rename_column(:items, :itemKey, :itemkey)
  end

  def self.down
    rename_column(:items, :itemkey, :itemKey)
  end
end
