module ApplicationHelper
  def getSourceDescription (id)
    Source.find(id).description
  end

  def getItemDescription (id)
    Item.find(id).description
  end
  
   def getCompetitorStyleDescription (id)
    CompetitorStyle.find(id).description
  end

  def isNewRow(someID)
    if @lastIDRow != someID then
      @lastIDRow = someID
      @isNewRow = true
      if @lastRowColor == "#ffffff" or @lastRowColor == nil then
        @lastRowColor = "#e3e3e3"
      else
        @lastRowColor = "#ffffff"
      end
    else
    @isNewRow = false
    end
  end
end
