require 'identifi-rpc'

class IdentifierController < ApplicationController
  def show
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    nodeID = IdentifiRails::Application.config.nodeID
    @authored = h.getpacketsbyauthor( params[:type], params[:value] )
    @received = h.getpacketsbyrecipient( params[:type], params[:value] )
    searchDepth = 3
    @trustpath = h.getpath(nodeID[0], nodeID[1], params[:type], params[:value], searchDepth.to_s)
    @mentionedWith = []

    @authoredPositive = 0
    @authoredNeutral = 0
    @authoredNegative = 0

    @authored.each do |m|
      signedData = m["data"]["signedData"]
      if signedData["type"] == "review"
        rating = signedData["rating"]
        neutralRating = (signedData["minRating"] + signedData["maxRating"]) / 2
        if rating > neutralRating
          @authoredPositive += 1
        elsif rating < neutralRating
          @authoredNegative += 1
        else
        	@authoredNeutral += 1
        end
      end
      signedData["author"].each do |a|
        @mentionedWith.push(a) unless a.second == params[:value]
      end
    end

    @receivedPositive = 0
    @receivedNeutral = 0
    @receivedNegative = 0

    @received.each do |m|
      signedData = m["data"]["signedData"]
      if signedData["type"] == "review"
        rating = signedData["rating"]
        neutralRating = (signedData["minRating"] + signedData["maxRating"]) / 2
        if rating > neutralRating
          @receivedPositive += 1
        elsif rating < neutralRating
          @receivedNegative += 1
        else
        	@receivedNeutral += 1
        end
      end
      signedData["recipient"].each do |a|
        @mentionedWith.push(a) unless a.second == params[:value]
      end
    end
  end

  def write
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    params.require(:type)
    params.require(:value)
    type = params[:type].to_s
    value = params[:value].to_s
    if current_user
      publish = Rails.env.production?.to_s
      if params[:rating]
        comment = (params[:comment].to_s or "")
        rating = params[:rating].to_s
        h.savepacket(current_user.provider, current_user.uid, type, value, comment, rating, publish)
      else
        params.require(:linkedType)
        params.require(:linkedValue)
        h.saveconnection(current_user.provider, current_user.uid, type, value, params[:linkedType].to_s, params[:linkedValue].to_s, publish) 
      end
    end
    redirect_to :action => 'show'
  end
end
