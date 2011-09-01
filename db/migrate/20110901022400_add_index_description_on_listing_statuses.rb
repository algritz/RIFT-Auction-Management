class AddIndexDescriptionOnListingStatuses < ActiveRecord::Migration
  def self.up
    add_index :listing_statuses, :description
  end

  def self.down
    remove_index :listing_statuses, :description
  end
end
