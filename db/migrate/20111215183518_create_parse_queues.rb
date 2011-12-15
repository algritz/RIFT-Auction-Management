class CreateParseQueues < ActiveRecord::Migration
  def change
    create_table :parse_queues do |t|
      t.integer :user_id
      t.text :content
      t.timestamps
    end
    add_index :parse_queues, :user_id
  end
end
