class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  def get_cache_stats
    p "stats called"
    p Rails.cache.stats
    #p @stats = Rails.cache.stats.first.last
  end

end
