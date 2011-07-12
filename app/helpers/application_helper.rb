module ApplicationHelper
  def getSourceDescription (id)
    Source.find(id).description
  end
end
