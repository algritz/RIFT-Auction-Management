class AddToListColumnToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :to_list, :boolean
  end

  def self.down
    remove_column :items, :to_list
  end
end
