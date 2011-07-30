module PageHelper
  def generate_data
    @data_str = "<table><tr align='left'><th>Item name</th><th>Profession</th><th>Crafting Cost</th></tr>"
    @out_of_stock_list.each do |item|
      isNewRow(item)
      @data_str+= "<tr bgcolor='#{@lastRowColor}'><td>#{getItemDescription(item)}</td><td style='padding-right:20px;'>#{getSourceDescriptionForItemsToCraft(item)}</td><td style='padding-right:20px;'>#{formatPrice(calculateCraftingCost(item))}</td>"
    end
    @data_str += "</table>"
  end

  def generate_data_bank
    @data_str_bank = "<table><tr align='left'><th>Item name</th><th>Profession</th><th>Crafting Cost</th></tr>"
    @sitting_in_bank.each do |item|
      isNewRow(item)
      @data_str_bank+= "<tr bgcolor='#{@lastRowColor}'><td>#{getItemDescription(item)}</td><td style='padding-right:20px;'>#{getSourceDescriptionForItemsToCraft(item)}</td><td style='padding-right:20px;'>#{formatPrice(calculateCraftingCost(item))}</td>"
    end
    @data_str_bank += "</table>"
  end

end