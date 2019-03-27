class ApplicationController < ActionController::Base

  def logged_in?
    session[:user_id].present?
  end
  helper_method :logged_in?

  def current_user
    return nil unless logged_in?
    @current_user ||= User.find_by_id(session[:user_id])
  end
  helper_method :current_user

  def require_login
    if !logged_in?
      render plain: "Access denied", status: 404
      return false
    end
  end

end
