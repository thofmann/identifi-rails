  require 'identifi-rpc'

class IdentifierController < ApplicationController
  MSG_COUNT = 10
  MSG_COUNT_S = MSG_COUNT.to_s
  NODE_ID = IdentifiRails::Application.config.nodeID
  IDENTIFI_PACKET = {
                      signedData:
                        {
                          timestamp: 0,
                          author: [],
                          recipient: [],
                          rating: 0,
                          maxRating: 1,
                          minRating: -1,
                          comment: "",
                          type: "review"
                        },
                      signature: {}
                    }

  before_filter :checkParams, :except => [:getconnectingpackets]

  def checkParams
    params.require(:type)
    params.require(:value)
  end

  def show
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    setViewpointName(h)
    offset = (params[:page].to_i * MSG_COUNT).to_s or "0"
    
    t1 = Time.now
    @authored = h.getpacketsbyauthor( params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:packet_type_filter] )
    logger.debug "getpacketsbyauthor completed in #{(Time.now - t1) * 1000}ms"
    
    t1 = Time.now
    if (session[:max_trust_distance] >= 0)
      @received = h.getpacketsbyrecipient( params[:type], params[:value], MSG_COUNT_S, offset, NODE_ID[0], NODE_ID[1], session[:max_trust_distance].to_s, session[:packet_type_filter] )
    else
      @received = h.getpacketsbyrecipient( params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:packet_type_filter] )
    end
    logger.debug "getpacketsbyrecipient completed in #{(Time.now - t1) * 1000}ms"

    t1 = Time.now
    if (session[:max_trust_distance] >= 0)
      @stats = h.overview( params[:type], params[:value], NODE_ID[0], NODE_ID[1], session[:max_trust_distance].to_s )
    else
      @stats = h.overview(params[:type], params[:value], "", "", "0" )
    end
    logger.debug "overview completed in #{(Time.now - t1) * 1000}ms"

    searchDepth = IdentifiRails::Application.config.maxPathSearchDepth
    t1 = Time.now
    if current_user
        @trustpath = h.getpath(current_user.provider, current_user.uid, params[:type], params[:value], searchDepth.to_s)
    else
        @trustpath = h.getpath(NODE_ID[0], NODE_ID[1], params[:type], params[:value], searchDepth.to_s)
    end
    logger.debug "getpath completed in #{(Time.now - t1) * 1000}ms"

    t1 = Time.now
    if (session[:max_trust_distance] >= 0)
      @connections = h.getconnections( params[:type], params[:value], "0", "0", NODE_ID[0], NODE_ID[1], session[:max_trust_distance].to_s )
    else
      @connections = h.getconnections( params[:type], params[:value] )
    end
    logger.debug "getconnections completed in #{(Time.now - t1) * 1000}ms"
  end

  def write
    if current_user
      h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
      params.require(:rating)
      type = params[:type].to_s
      value = params[:value].to_s
      rating = params[:rating].to_i
      comment = (params[:comment].to_s or "")
      publish = Rails.env.production?.to_s

      message = Marshal.load(Marshal.dump(IDENTIFI_PACKET))
      message[:signedData][:author].push([current_user.provider, current_user.uid])
      message[:signedData][:author].push(["name", current_user.name]) if current_user.name
      message[:signedData][:author].push(["nickname", current_user.nickname]) if current_user.nickname
      message[:signedData][:author].push(["url", current_user.url]) if current_user.url
      message[:signedData][:recipient].push([type, value])
      message[:signedData][:rating] = rating
      message[:signedData][:comment] = comment unless comment.empty?
      message[:signedData][:timestamp] = Time.now.to_i
      h.savepacketfromdata(message.to_json, publish.to_s)
    end
    redirect_to :action => 'show', :type => params[:type], :value => params[:value]
  end

  def sent
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    offset = (params[:page].to_i * MSG_COUNT).to_s or "0"
    @messages = h.getpacketsbyauthor( params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:packet_type_filter] )
    render :partial => "messages"
  end

  def received
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    offset = (params[:page].to_i * MSG_COUNT).to_s or "0"
    if (session[:max_trust_distance] >= 0)
      @messages = h.getpacketsbyrecipient( params[:type], params[:value], MSG_COUNT_S, offset, NODE_ID[0], NODE_ID[1], session[:max_trust_distance].to_s, session[:packet_type_filter] )
    else
      @messages = h.getpacketsbyrecipient( params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:packet_type_filter] )
    end
    render :partial => "messages"
  end

  def confirm
    connection(true)
  end

  def refute
    connection(false)
  end

  def connection(confirm)
    if params.has_key?(:linkedComment)
      connectioncomment(confirm)
    elsif current_user
      h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
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
  
  def connectioncomment(confirm)
    if current_user
      h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
      params.require(:linkedType)
      params.require(:linkedValue)
      type = params[:type].to_s
      value = params[:value].to_s
      publish = Rails.env.production?.to_s
      comment = params[:linkedComment].to_s
      message = Marshal.load(Marshal.dump(IDENTIFI_PACKET))

      message[:signedData][:timestamp] = Time.now.to_i
      message[:signedData][:author].push([current_user.provider, current_user.uid])
      message[:signedData][:recipient].push([type, value])
      message[:signedData][:recipient].push([params[:linkedType], params[:linkedValue]])
      message[:signedData][:type] = confirm ? "confirm_connection" : "refute_connection"
      message[:signedData][:comment] = comment unless comment.empty?
      h.savepacketfromdata(message.to_json, publish.to_s)

      render :text => "OK"
    else
      render :text => "Login required", :status => 401
    end
  end

  def overview
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    if (session[:max_trust_distance] >= 0)
      @stats = h.overview(params[:type].to_s, params[:value].to_s, NODE_ID[0], NODE_ID[1], session[:max_trust_distance].to_s)
    else
      @stats = h.overview(params[:type].to_s, params[:value].to_s)
    end
    render :partial => "overview"
  end

  def getconnectingpackets
    params.require(:id1type)
    params.require(:id2type)
    params.require(:id1value)
    params.require(:id2value)
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    if (session[:max_trust_distance] >= 0)
      @messages = h.getconnectingpackets(params[:id1type], params[:id1value], params[:id2type], params[:id2value], "0", "0", NODE_ID[0], NODE_ID[1], session[:max_trust_distance].to_s )
    else
      @messages = h.getconnectingpackets(params[:id1type], params[:id1value], params[:id2type], params[:id2value])
    end
    render :partial => "messages"
  end
end
