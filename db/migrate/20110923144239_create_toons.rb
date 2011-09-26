class CreateToons < ActiveRecord::Migration
  def self.up
    create_table :toons do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :toons
  end
end
