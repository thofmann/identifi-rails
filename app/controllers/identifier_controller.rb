require 'identifi-rpc'

class IdentifierController < ApplicationController
  MSG_COUNT = 15
  MSG_COUNT_S = MSG_COUNT.to_s
  IDENTIFI_PACKET = {
                      signedData:
                        {
                          timestamp: 0,
                          author: [],
                          recipient: [],
                          rating: 0,
                          maxRating: 3,
                          minRating: -3,
                          comment: "",
                          type: "rating"
                        },
                      signature: {}
                    }

  before_filter :checkParams, :except => [:getconnectingmsgs]

  def checkParams
    params.require(:type)
    params.require(:value)
  end

  def setGravatarHash(params)
    if params[:type] == "email"
      @gravatarEmail = params[:value].downcase
    elsif @connections
      emailId = @connections.find { |id| id["type"] == "email" && (id["confirmations"] >= id["refutations"]) }
      @gravatarEmail = emailId["value"].downcase if emailId
    end

    @gravatarEmail = "#{params[:type]}:#{params[:value]}" unless @gravatarEmail
    @gravatarHash = Digest::MD5.hexdigest(@gravatarEmail)
  end

  def setTrustpaths(tp, identifi)
    @trustpaths = []
    return if tp.empty?
    tp = tp.select { |p| p.size == tp.first.size }
    @trustpaths = Array.new(tp.first.size) {|i| Set.new }
    tp.each do |p|
      p.each_index { |i| @trustpaths[i] << p[i] }
    end
    if @trustpaths.size > 2
      @trustpaths[1..-1].each do |idSet|
        idSet.each do |id|
          id[2] = identifi.getname(id[0], id[1])
          id[2] = nil if id[2].empty?
          email = identifi.getcachedemail(id[0], id[1])
          email = "#{id[0]}:#{id[1]}" if email.empty?
          id[3] = Digest::MD5.hexdigest(email)
        end
      end
    end
  end

  def fixUrlParams(params)
    # Rails messes these up in get requests. Maybe a better fix could be found.
    params[:value] = params[:value].sub(':/', '://')
  end

  def show
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    setViewpoint(h)
    fixUrlParams(params)
    offset = (params[:page].to_i * MSG_COUNT).to_s or "0"
    @googlePlusUrl = params[:value] if (params[:type] == "url" and /https:\/\/plus.google.com/.match(params[:value]))
    @isTrustPathable = IdentifiRails::Application.config.trustPathableTypes.include? params[:type]
    
    t1 = Time.now
    @connections = h.getconnections(*getconnections_args(params, session))
    logger.debug "getconnections completed in #{(Time.now - t1) * 1000}ms"

    if @isTrustPathable 
      t1 = Time.now
      @authored = h.getmsgsbyauthor( params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:msg_type_filter] )
      logger.debug "getmsgsbyauthor completed in #{(Time.now - t1) * 1000}ms"
      setGravatarsAndLinks(@authored)
      
      t1 = Time.now
      @received = h.getmsgsbyrecipient(*getmsgsbyrecipient_args(params, session, offset))
      logger.debug "getmsgsbyrecipient completed in #{(Time.now - t1) * 1000}ms"
      setGravatarsAndLinks(@received)

      t1 = Time.now
      trustpaths = h.getpaths(*getpaths_args(params, session))
      logger.debug "getpaths completed in #{(Time.now - t1) * 1000}ms"
      
      setTrustpaths(trustpaths, h)
    end

    setGravatarHash(params)

    t1 = Time.now
    @stats = h.overview(*overview_args(params, session))
    logger.debug "overview completed in #{(Time.now - t1) * 1000}ms"

    if (@stats["name"].nil? or @stats["name"].empty?)
      @pageTitle = params[:value]
    else
      @pageTitle = @stats["name"]
    end
  end

  def write
    if current_user
      h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
      setViewpoint(h)
      params.require(:rating)
      type = params[:type].to_s
      value = params[:value].to_s
      rating = params[:rating].to_i
      comment = (params[:comment].to_s or "")
      publish = Rails.env.production?.to_s

      message = Marshal.load(Marshal.dump(IDENTIFI_PACKET))
      message[:signedData][:author].push([current_user.type, current_user.value])
      message[:signedData][:author].push(["name", current_user.name]) if \
        (current_user.name and current_user.type != "email")
      message[:signedData][:author].push(["nickname", current_user.nickname]) if current_user.nickname
      message[:signedData][:recipient].push([type, value])
      message[:signedData][:rating] = rating
      message[:signedData][:comment] = comment unless comment.empty?
      message[:signedData][:timestamp] = Time.now.to_i
      h.delete_cached("getmsgsbyrecipient", getmsgsbyrecipient_args(params, session, "0"))
      h.delete_cached("overview", overview_args(params, session))
      h.delete_cached("getpaths", getpaths_args(params, session))
      h.savemsgfromdata(message.to_json, publish.to_s)
      h.generatetrustmap(current_user.type, current_user.value, \
                         IdentifiRails::Application.config.generateTrustMapDepth.to_s) if rating > 0 
    end
    redirect_to :action => 'show', :type => params[:type], :value => params[:value]
  end

  def sent
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    fixUrlParams(params)
    offset = (params[:page].to_i * MSG_COUNT).to_s or "0"
    @messages = h.getmsgsbyauthor( params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:msg_type_filter] )
    setGravatarsAndLinks(@messages)
    render :partial => "messages"
  end

  def received
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    setViewpoint(h)
    fixUrlParams(params)
    offset = (params[:page].to_i * MSG_COUNT).to_s or "0"
    if (session[:max_trust_distance] >= 0)
      @messages = h.getmsgsbyrecipient( params[:type], params[:value], MSG_COUNT_S, offset, @viewpointType, @viewpointValue, session[:max_trust_distance].to_s, session[:msg_type_filter] )
    else
      @messages = h.getmsgsbyrecipient( params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:msg_type_filter] )
    end
    setGravatarsAndLinks(@messages)
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
      setViewpoint(h)
      h.delete_cached("getconnections", getconnections_args(params, session))
      params.require(:linkedType)
      params.require(:linkedValue)
      type = params[:type].to_s
      value = params[:value].to_s
      publish = Rails.env.production?.to_s
      if confirm
        h.saveconnection(current_user.type, current_user.value, type, value, params[:linkedType].to_s, params[:linkedValue].to_s, publish)
        h.generatetrustmap(type, value, IdentifiRails::Application.config.generateTrustMapDepth.to_s) if (current_user.type == type and current_user.value == value)
      else
        h.refuteconnection(current_user.type, current_user.value, type, value, params[:linkedType].to_s, params[:linkedValue].to_s, publish)
      end
      render :text => "OK"
    else
      render :text => "Login required", :status => 401
    end
  end
  
  def connectioncomment(confirm)
    if current_user
      h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
      setViewpoint(h)
      h.delete_cached("getconnections", getconnections_args(params, session))
      params.require(:linkedType)
      params.require(:linkedValue)
      type = params[:type].to_s
      value = params[:value].to_s
      publish = Rails.env.production?.to_s
      comment = params[:linkedComment].to_s
      message = Marshal.load(Marshal.dump(IDENTIFI_PACKET))

      message[:signedData][:timestamp] = Time.now.to_i
      message[:signedData][:author].push([current_user.type, current_user.value])
      message[:signedData][:recipient].push([type, value])
      message[:signedData][:recipient].push([params[:linkedType], params[:linkedValue]])
      message[:signedData][:type] = confirm ? "confirm_connection" : "refute_connection"
      message[:signedData][:comment] = comment unless comment.empty?
      h.savemsgfromdata(message.to_json, publish.to_s)
      h.generatetrustmap(type, value, IdentifiRails::Application.config.generateTrustMapDepth.to_s) if (confirm and current_user.type == type and current_user.value == value)

      render :text => "OK"
    else
      render :text => "Login required", :status => 401
    end
  end

  def overview
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    setViewpoint(h)
    @stats = h.overview(*overview_args(params, session))
    if params[:type] == "email"
      gravatarEmail = params[:value] 
    elsif (@stats["email"] and not @stats["email"].empty?) 
      gravatarEmail = @stats["email"] 
    else
      gravatarEmail = "#{params[:type]}:#{params[:value]}"
    end
    @stats["gravatarHash"] = getGravatarHash(gravatarEmail)
    render :partial => "overview"
  end

  def getconnectingmsgs
    params.require(:id1type)
    params.require(:id2type)
    params.require(:id1value)
    params.require(:id2value)
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    setViewpoint(h)
    if (session[:max_trust_distance] >= 0)
      @messages = h.getconnectingmsgs(params[:id1type], params[:id1value], params[:id2type], params[:id2value], "0", "0", @viewpointType, @viewpointValue, session[:max_trust_distance].to_s )
    else
      @messages = h.getconnectingmsgs(params[:id1type], params[:id1value], params[:id2type], params[:id2value])
    end
    setGravatarsAndLinks(@messages)
    render partial: "confirmation", collection: @messages
  end

  private
  def getmsgsbyrecipient_args(params, session, offset)
    if (session[:max_trust_distance] >= 0)
      return [params[:type], params[:value], MSG_COUNT_S, offset, @viewpointType, @viewpointValue, session[:max_trust_distance].to_s, session[:msg_type_filter]]
    else
      return [params[:type], params[:value], MSG_COUNT_S, offset, "", "", "0", session[:msg_type_filter]]
    end
  end

  def overview_args(params, session)
    if (session[:max_trust_distance] >= 0)
      return [params[:type], params[:value], @viewpointType, @viewpointValue, session[:max_trust_distance].to_s]
    else
      return [params[:type], params[:value], "", "", "0"]
    end

  end

  def getconnections_args(params, session)
    if (session[:max_trust_distance] >= 0)
      return [ params[:type], params[:value], "0", "0", @viewpointType, @viewpointValue, session[:max_trust_distance].to_s ]
    else
      return [ params[:type], params[:value] ]
    end
  end

  def getpaths_args(params, session)
    searchDepth = IdentifiRails::Application.config.maxPathSearchDepth
    [@viewpointType, @viewpointValue, params[:type], params[:value], searchDepth.to_s]
  end
end
