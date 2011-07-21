class PageController < ApplicationController
  def items_to_list
    getItemToList
    p @out_of_stock_list
    items = @out_of_stock_list[1..-2].split(',').collect!
    p items
  end

  ## start of private block ##
  private

  def getItemToList
    item_ids = Item.find(:all, :conditions => "to_list = 't'", :select => "id")
    @out_of_stock_list = []
    item_ids.each do |ids|
      active_autions = SalesListing.count(ids.id, :conditions => "item_id = #{ids.id} and listing_status_id <> 3")
      if active_autions == 0 then
        @out_of_stock_list << ids.id << ","
      end
    end
    @out_of_stock_list = @out_of_stock_list.to_s.chop.to_a
  end

end
