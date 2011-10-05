module PageHelper
  def competitionLevel(id)
    total_auctions = SalesListing.count(:conditions => ["item_id = ? and user_id = ?", id, @current_user.id], :select => "id")
    undercut_auctions = SalesListing.count(:conditions => ["item_id = ? and is_undercut_price = ? and user_id = ?", id, true, @current_user.id], :select => "id, is_undercut_price")
    competition_percentage = (undercut_auctions.to_f / total_auctions.to_f) * 100
    competition_percentage = format("%.2f",competition_percentage)
    if competition_percentage == "0.00" then
      competition_percentage = "Monopoly"
    else if competition_percentage == "NaN" then
        competition_percentage = "Never listed"
      else
        case competition_percentage.to_i
        when 0..20 then "Very Low"
        when 21..40 then "Low"
        when 41..60 then "Moderate"
        when 61..80 then "High"
        when 81..90 then "Very High"
        when 91..100 then "Extreme"
        end
      end
    end
  end
  
  def taintLevel(id)
    total_auctions = SalesListing.count(:id, :conditions => ["item_id = ? and user_id = ?", id, @current_user.id], :select => "id")
    undercut_auctions = SalesListing.count(:id, :conditions => ["item_id = ? and is_tainted = ? and user_id = ?", id, true, @current_user.id], :select => "id, is_tainted")
    competition_percentage = (undercut_auctions.to_f / total_auctions.to_f) * 100
    competition_percentage = format("%.2f",competition_percentage)
    if competition_percentage == "0.00" then
      competition_percentage = "Sane"
    else if competition_percentage == "NaN" then
        competition_percentage = "Never listed"
      else
        case competition_percentage.to_i
        when 0..10 then "Tolerable"
        when 11..90 then "Caution"  
        when 81..90 then "Hazardous"
        when 51..100 then "Toxic"
        end
      end
    end
  end
  
  def average_profit(id)
    profit = formatPrice(SalesListing.average_profit_cached_for_user(id, @current_user.id).to_i)
  end
  
  def market_confidence(item)
    total_listings = SalesListing.count(:id, :conditions => ["item_id = ? and user_id = ?", item, current_user[:id]])
    percentage = (total_listings.to_f / 25.to_f) * 100
    format("%.2f", percentage)
  end
  
end