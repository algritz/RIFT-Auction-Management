module CraftedItemsHelper
  def getDefaultItemValue
    if params[:item_id] != nil then
      crafted_item_generated_id = params[:item_id]
    crafted_item_generated_id
    else
    @crafted_item.crafted_item_generated_id
    end
  end
end
