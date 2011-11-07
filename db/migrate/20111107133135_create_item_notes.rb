class CreateItemNotes < ActiveRecord::Migration
  def change
    create_table :item_notes do |t|

      t.integer :item_id

      t.integer :user_id

      t.text :note


      t.timestamps

    end



  end
end
