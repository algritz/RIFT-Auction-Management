module SessionsHelper
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user = user
  end

  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_remember_token
  end

  def signed_in?
    !current_user.nil?
  end

  def is_admin?
    if signed_in? then
      current_user.is_admin?
    end
  end

  def is_current_user?(user)
    if signed_in? then
      current_user.id == user
    end
  end

  def authenticate
    deny_access unless signed_in?
  end
  
  def authenticate_admin
    deny_access_admin unless is_admin?
  end

  def deny_access
    redirect_to signin_path, :notice => "You need to be signed-in to see that page."
  end
  
  def deny_access_admin
    redirect_to signin_path, :notice => "You need to be an administrator to see that page."
  end
  ## Start of Private Block ##
  private

  def user_from_remember_token
    User.authenticate_with_salt(*remember_token)
  end

  def remember_token
    cookies.signed[:remember_token] || [nil, nil]
  end
## End of Private Block ##
end
