module PageHelper
  def competitionLevel(id)
    total_auctions = SalesListing.count(:conditions => ["item_id = ?", id], :select => "id")
    undercut_auctions = SalesListing.count(:conditions => ["item_id = ? and is_undercut_price = ?", id, true], :select => "id, is_undercut_price")
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
end