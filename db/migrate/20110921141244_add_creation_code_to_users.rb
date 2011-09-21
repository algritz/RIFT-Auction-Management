class AddCreationCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :creation_code, :string
  end

  def self.down
    remove_column :users, :creation_code
  end
end
