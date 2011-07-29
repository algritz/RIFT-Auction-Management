class AddPositionColumnToListingStatuses < ActiveRecord::Migration
  def self.up
    add_column :listing_statuses, :position, :integer
  end

  def self.down
    remove_column :listing_statuses, :position
  end
end
