class AddIndexToItemkeyOnItems < ActiveRecord::Migration
  def self.up
  add_index :items, :itemKey
  end

  def self.down
    remove_index :items, :itemKey
  end
end
