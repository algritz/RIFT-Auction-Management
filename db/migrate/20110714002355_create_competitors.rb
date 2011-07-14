class CreateCompetitors < ActiveRecord::Migration
  def self.up
    create_table :competitors do |t|
      t.string :name
      t.integer :competitor_style_id
      t.integer :source_id

      t.timestamps
    end
  end

  def self.down
    drop_table :competitors
  end
end
