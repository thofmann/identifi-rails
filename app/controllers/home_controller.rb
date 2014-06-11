require 'identifi-rpc'

class HomeController < ApplicationController
  MSG_COUNT = 10
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    nodeID = IdentifiRails::Application.config.nodeID
    setViewpointName(h)
    offset = (params[:page].to_i * MSG_COUNT) or 0
    if (session[:max_trust_distance] >= 0)
      @latest = h.getlatestpackets( MSG_COUNT.to_s, offset.to_s, nodeID[0], nodeID[1], session[:max_trust_distance].to_s, session[:packet_type_filter] )
    else
      @latest = h.getlatestpackets( MSG_COUNT.to_s, offset.to_s, "", "", "0", session[:packet_type_filter] )
    end
  end

  def feed
    index
  end

  def about
  end
end
