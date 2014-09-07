class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    if h.gettrustmapsize(current_user.type, current_user.value) < 50
        h.generatetrustmap(current_user.type, current_user.value)
    end
    redirect_to request.env['omniauth.origin'] || root_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

  def settings
    session[:max_trust_distance] = params[:max_trust_distance].to_i if params[:max_trust_distance]
    session[:msg_type_filter] = params[:msg_type_filter] if params[:msg_type_filter]
    render :nothing => true, :status => 200
  end
end
