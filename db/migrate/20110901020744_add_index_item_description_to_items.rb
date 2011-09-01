class AddIndexItemDescriptionToItems < ActiveRecord::Migration
    def self.up
     add_index :items, :description
  end

  def self.down
    remove_index :items, :description
  end
end
