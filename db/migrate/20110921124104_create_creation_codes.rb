class CreateCreationCodes < ActiveRecord::Migration
  def self.up
    create_table :creation_codes do |t|
      t.string :creation_code
      t.boolean :used

      t.timestamps
    end
  end

  def self.down
    drop_table :creation_codes
  end
end
