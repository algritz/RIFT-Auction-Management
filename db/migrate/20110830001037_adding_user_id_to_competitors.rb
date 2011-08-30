class AddingUserIdToCompetitors < ActiveRecord::Migration
  def self.up
    add_column :competitors, :user_id, :integer
    add_index :competitors, :user_id
  end

  def self.down
    remove_column :competitors, :user_id
    remove_index :competitors, :user_id
  end
end
