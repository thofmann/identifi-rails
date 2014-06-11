class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :setSessionDefaults

  private
  def setSessionDefaults
    session[:max_trust_distance] = 0 unless session[:max_trust_distance]
    session[:packet_type_filter] = "" unless session[:packet_type_filter]
  end

  def setViewpointName(identifiRPC)
    nodeID = IdentifiRails::Application.config.nodeID
    @viewpointName = identifiRPC.getname(nodeID[0], nodeID[1])
    @viewpointName = nil if @viewpointName.empty?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
