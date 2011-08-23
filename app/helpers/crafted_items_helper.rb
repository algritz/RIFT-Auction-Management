module CraftedItemsHelper
  def getDefaultItemValue
    if params[:item_id] != nil then
      crafted_item_generated_id = params[:item_id]
    crafted_item_generated_id
    else
    @crafted_item.crafted_item_generated_id
    end
  end

  def getDefaultItemStacksize
    if params[:item_id] != nil then
      crafted_item_generated_id = params[:item_id]
      crafted_item_stacksize = CraftedItem.find(:last, :conditions => ["crafted_item_generated_id = ?", crafted_item_generated_id], :select => 'crafted_item_stacksize').crafted_item_stacksize
    else
    @crafted_item.crafted_item_stacksize
    end
  end
end
