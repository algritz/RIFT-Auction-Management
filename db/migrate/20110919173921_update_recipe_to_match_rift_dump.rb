class UpdateRecipeToMatchRiftDump < ActiveRecord::Migration
  def self.up
    add_column :crafted_items, :required_skill, :string
    add_column :crafted_items, :required_skill_point, :integer
    add_column :crafted_items, :rift_id, :integer
    add_column :crafted_items, :name, :string
    add_index :crafted_items, :required_skill
    add_index :crafted_items, :required_skill_point
  end

  def self.down
    remove_column :crafted_items, :required_skill
    remove_column :crafted_items, :required_skill_point
    remove_column :crafted_items, :rift_id
    remove_column :crafted_items, :name
    remove_index :crafted_items, :required_skill
    remove_index :crafted_items, :required_skill_point    
  end
end
