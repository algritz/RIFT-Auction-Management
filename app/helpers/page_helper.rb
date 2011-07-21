module PageHelper
  def generate_data
    @data_str = "<table><th align='left'>Item name</th><th>Profession</th>"
    @out_of_stock_list.each do |item|
      @data_str+= "<tr><td style='padding-right:20px;'>#{getItemDescription(item)}</td><td>#{getSourceDescriptionForItemsToCraft(item)}</td>"
    end
    @data_str += "</table>"
  end
  @data_str
end