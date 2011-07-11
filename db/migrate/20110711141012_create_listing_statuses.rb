class CreateListingStatuses < ActiveRecord::Migration
  def self.up
    create_table :listing_statuses do |t|
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :listing_statuses
  end
end
