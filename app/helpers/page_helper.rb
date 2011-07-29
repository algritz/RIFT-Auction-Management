module PageHelper
  def generate_data
    @data_str = "<table><th align='left' style='padding-right:20px;'>Item name</th><th>Profession</th>"   
    @out_of_stock_list.each do |item|
      isNewRow(item)
      @data_str+= "<tr bgcolor='#{@lastRowColor}'><td style='padding-right:20px;'>#{getItemDescription(item)}</td><td style='padding-right:20px;'>#{getSourceDescriptionForItemsToCraft(item)}</td>"
    end
    @data_str += "</table>"
  end
  
  def generate_data_bank
    @data_str_bank = "<table><th align='left' style='padding-right:20px;'>Item name</th><th>Profession</th>"   
    @sitting_in_bank.each do |item|
      isNewRow(item)
      @data_str_bank+= "<tr bgcolor='#{@lastRowColor}'><td style='padding-right:20px;'>#{getItemDescription(item)}</td><td style='padding-right:20px;'>#{getSourceDescriptionForItemsToCraft(item)}</td>"
    end
    @data_str_bank += "</table>"
  end
  
end