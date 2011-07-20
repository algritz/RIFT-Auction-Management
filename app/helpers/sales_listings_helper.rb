module SalesListingsHelper
  def getDefaultStacksize
   # p params
  end
  
  def returnStackSize
    #p params
  end
  
  def getItemToList
    item_list = CraftedItem.find(:all, :select => "crafted_item_generated_id")
    p CraftedItem.where("crafted_item_generated_id = #{SalesListing.find(:all).item_id}").exists?
    
    item_list.each do |item|
      p item.class
     #item_list_to_craft =  SalesListing.find(:all, :conditions => "item_id = #{value}")
    end
    
  end
    
end
