module SalesListingsHelper
  def determineDefaultStacksize (f)
    p params
    f+".options[this.selectedIndex].value"
  end
end
