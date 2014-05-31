  require 'identifi-rpc'

class IdentifierController < ApplicationController
  MSG_COUNT = 10
  def show
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    nodeID = IdentifiRails::Application.config.nodeID
    offset = (params[:page].to_i * MSG_COUNT) or 0
    
    t1 = Time.now
    @authored = h.getpacketsbyauthor( params[:type], params[:value], MSG_COUNT, offset )
    logger.debug "getpacketsbyauthor completed in #{(Time.now - t1) * 1000}ms"
    
    t1 = Time.now
    @received = h.getpacketsbyrecipient( params[:type], params[:value], MSG_COUNT, offset )
    logger.debug "getpacketsbyrecipient completed in #{(Time.now - t1) * 1000}ms"

    t1 = Time.now
    @stats = h.overview(params[:type], params[:value])
    logger.debug "overview completed in #{(Time.now - t1) * 1000}ms"

    searchDepth = 3
    t1 = Time.now
    @trustpath = h.getpath(nodeID[0], nodeID[1], params[:type], params[:value], searchDepth.to_s)
    logger.debug "getpath completed in #{(Time.now - t1) * 1000}ms"

    t1 = Time.now
    @connections = h.getconnections( params[:type], params[:value] )
    logger.debug "getconnections completed in #{(Time.now - t1) * 1000}ms"
  end

  def write
    if current_user
      h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
      params.require(:type)
      params.require(:value)
      params.require(:rating)
      type = params[:type].to_s
      value = params[:value].to_s
      rating = params[:rating].to_s
      comment = (params[:comment].to_s or "")
      publish = Rails.env.production?.to_s
      h.savepacket(current_user.provider, current_user.uid, type, value, comment, rating, publish)
    end
    redirect_to :action => 'show'
  end

  def sent
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    params.require(:type)
    params.require(:value)
    offset = (params[:page].to_i * MSG_COUNT) or 0
    @messages = h.getpacketsbyauthor( params[:type], params[:value], MSG_COUNT, offset )
    render :partial => "messages"
  end

  def received
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    params.require(:type)
    params.require(:value)
    offset = (params[:page].to_i * MSG_COUNT) or 0
    @messages = h.getpacketsbyrecipient( params[:type], params[:value], MSG_COUNT, offset )
    render :partial => "messages"
  end

  def confirm
    connection(true)
  end

  def refute
    connection(false)
  end

  def connection(confirm)
    if current_user
      h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
      params.require(:type)
      params.require(:value)
      params.require(:linkedType)
      params.require(:linkedValue)
      type = params[:type].to_s
      value = params[:value].to_s
      publish = Rails.env.production?.to_s
      if confirm
        h.saveconnection(current_user.provider, current_user.uid, type, value, params[:linkedType].to_s, params[:linkedValue].to_s, publish) 
      else
        h.refuteconnection(current_user.provider, current_user.uid, type, value, params[:linkedType].to_s, params[:linkedValue].to_s, publish) 
      end
      render :text => "OK"
    else
      render :text => "Login required", :status => 401
    end
  end

  def overview
    params.require(:type)
    params.require(:value)
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @stats = h.overview(params[:type].to_s, params[:value].to_s)
    render :partial => "overview"
  end

  def getconnectingpackets
    params.require(:id1type)
    params.require(:id2type)
    params.require(:id1value)
    params.require(:id2value)
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @messages = h.getconnectingpackets(params[:id1type], params[:id1value], params[:id2type], params[:id2value])
    render :partial => "messages"
  end
end
