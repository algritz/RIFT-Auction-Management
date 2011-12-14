class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  before_filter :init
  def init
    @start_time = Time.now
  end
  
  def my_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/my.log")
  end

end
