class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate
    redirect_to login_path, :notice => 'you should be logged in' if current_user.nil? or not current_user.admin
  end

  def admin?
    not current_user.nil? and current_user.admin
  end

  helper_method :current_user, :authenticate, :admin?
end
