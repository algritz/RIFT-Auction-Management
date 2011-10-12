class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  before_filter :init
  def init
    @start_time = Time.now
  end
end
