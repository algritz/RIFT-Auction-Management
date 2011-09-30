class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  require 'will_paginate/array'

  def get_cache_stats
    @stats = Rails.cache.stats.first.last
  end

end
