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

  def do_update symbol, params
    name = symbol.to_s
    klass = name.classify.constantize
    instance = klass.find( params[:id] )
    instance_variable_set("@#{name}", instance)
    if instance.update.attributes(params[symbol] )
      redirect_to instance, :notice => "#{klass} was successfully updated."
    else
      render :action => "edit"
    end
  end
end
