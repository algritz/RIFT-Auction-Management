class PageController < ApplicationController
  def items_to_list
    item_ids = Item.find(:all, :conditions => "to_list = 't'", :select => "id")
    @out_of_stock_list = []
    item_ids.each do |ids|
      active_autions = SalesListing.count(ids.id, :conditions => "item_id = #{ids.id} and listing_status_id <> 3")
      if active_autions == 0 then
      @out_of_stock_list << ids.id
      end
    end
    @out_of_stock_list_desc = []
    @out_of_stock_list.each do |item_list|
      @out_of_stock_list_desc << getItemDescription(item_list)
    end
  end

  def getItemDescription (id)
    Item.find(id).description
  end

end
