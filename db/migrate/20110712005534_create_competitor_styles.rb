class CreateCompetitorStyles < ActiveRecord::Migration
  def self.up
    create_table :competitor_styles do |t|
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :competitor_styles
  end
end
