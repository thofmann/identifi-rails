  require 'identifi-rpc'

class IdentifierController < ApplicationController
  def show
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    nodeID = IdentifiRails::Application.config.nodeID
    offset = 0
    offset = params[:offset] if params[:offset]
    @authored = h.getpacketsbyauthor( params[:type], params[:value], 10, offset )
    @received = h.getpacketsbyrecipient( params[:type], params[:value], 10, offset )
    @stats = h.overview(params[:type], params[:value])
    searchDepth = 3
    @trustpath = h.getpath(nodeID[0], nodeID[1], params[:type], params[:value], searchDepth.to_s)
    @mentionedWith = []
    @confirmationCount = Hash.new(0)
    @refutationCount = Hash.new(0)

    @authored.each do |m|
      signedData = m["data"]["signedData"]
      signedData["author"].each do |a|
        unless a == [params[:type], params[:value]]
          @confirmationCount[a] += 1
          @mentionedWith.push(a) unless @mentionedWith.include?(a)
        end
      end
    end

    @received.each do |m|
      signedData = m["data"]["signedData"]
      signedData["recipient"].each do |a|
        unless a == [params[:type], params[:value]]
          if signedData["type"] == "refute_connection"
            @refutationCount[a] += 1
          else
            @confirmationCount[a] += 1
          end
          @mentionedWith.push(a) unless @mentionedWith.include?(a)
        end
      end
    end
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
end
