class AddIsFinalToListingStatuses < ActiveRecord::Migration
  def self.up
    add_column :listing_statuses, :is_final, :boolean, :default => false
  end

  def self.down
    remove_column :listing_statuses, :is_final
  end
end
