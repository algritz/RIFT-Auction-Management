class CreateToonSkillLevels < ActiveRecord::Migration
  def self.up
    create_table :toon_skill_levels do |t|
      t.integer :toon_id
      t.integer :source_id
      t.integer :skill_level

      t.timestamps
    end
  end

  def self.down
    drop_table :toon_skill_levels
  end
end
