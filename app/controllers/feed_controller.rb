require 'identifi-rpc'

class FeedController < ApplicationController
  MSG_COUNT = 15
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    setViewpoint(h)
    offset = (params[:page].to_i * MSG_COUNT) or 0
    if (session[:max_trust_distance] >= 0)
      @latest = h.getlatestmsgs( MSG_COUNT.to_s, offset.to_s, @viewpointType, @viewpointValue, session[:max_trust_distance].to_s, session[:msg_type_filter] )
    else
      @latest = h.getlatestmsgs( MSG_COUNT.to_s, offset.to_s, "", "", "0", session[:msg_type_filter] )
    end
    setGravatarsAndLinks(@latest)
    if current_user
      @userOverview = h.overview(current_user.type, current_user.value.to_s, @viewpointType, @viewpointValue)
      setGravatarHash(@userOverview)
      total = (@userOverview["receivedPositive"] + @userOverview["receivedNeutral"] + @userOverview["receivedNegative"])
      if total > 0
        @userOverview[:score] = @userOverview["receivedPositive"].to_f / total * 100
      else
        @userOverview[:score] = "-"
      end
    end
  end

  def feed
    index
  end

  def about
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @msgCount = h.getmsgcount
    @identifierCount = h.getidentifiercount
  end
  
  def setGravatarHash(overview)
    if current_user.type == "email"
      @gravatarEmail = current_user.value.downcase
    elsif not overview["email"].empty?
      @gravatarEmail = overview["email"].downcase
    end

    @gravatarEmail = "#{current_user.type}:#{current_user.value}" unless @gravatarEmail
    @gravatarHash = Digest::MD5.hexdigest(@gravatarEmail)
  end
end
