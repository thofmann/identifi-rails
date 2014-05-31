class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

  def settings
    session[:trusted_only] = (params[:trusted_only].to_i != 0) if params[:trusted_only]
    render :nothing => true, :status => 200
  end
end