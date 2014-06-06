require 'identifi-rpc'

class HomeController < ApplicationController
  MSG_COUNT = 10
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    offset = (params[:page].to_i * MSG_COUNT) or 0
    if (session[:trusted_only])
      nodeID = IdentifiRails::Application.config.nodeID
      @latest = h.getlatestpackets( MSG_COUNT.to_s, offset.to_s, nodeID[0], nodeID[1] )
    else
      @latest = h.getlatestpackets( MSG_COUNT.to_s, offset.to_s )
    end
  end

  def feed
    index
  end

  def info
  end
end
