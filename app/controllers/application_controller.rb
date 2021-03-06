class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :setSessionDefaults

  private
  def setSessionDefaults
    session[:max_trust_distance] = 0 unless session[:max_trust_distance]
    session[:msg_type_filter] = "rating" unless session[:msg_type_filter]
    @googleAnalyticsTrackingID = IdentifiRails::Application.config.googleAnalyticsTrackingID if (IdentifiRails::Application.config.googleAnalyticsTrackingID != '')
  end

  def setViewpoint(identifiRPC)
    @nodeID = IdentifiRails::Application.config.nodeID
    @nodeName = IdentifiRails::Application.config.nodeName
    if current_user
      @viewpointType = current_user.type
      @viewpointValue = current_user.value
      @viewpointName = current_user.name if current_user.name
    else
      @viewpointType = @nodeID[0]
      @viewpointValue = @nodeID[1]
      @viewpointName = @nodeName
    end
    @viewpointName = identifiRPC.getname(@viewpointType, @viewpointValue) unless @viewpointName
    @viewpointName = @viewpointValue if @viewpointName.empty?
    e = identifiRPC.getcachedemail(@viewpointType, @viewpointValue)
    e = "#{@viewpointType}:#{@viewpointValue}" if e.empty?
    @viewpointGravatarHash = Digest::MD5.hexdigest(e)
  end

  def setGravatarsAndLinks(messages, gravatarForRecipient = false)
    messages.each do |m|
      authorEmail = m["authorEmail"] if (m["authorEmail"] and not m["authorEmail"].empty?)
      authorEmail = "#{m["data"]["signedData"]["author"][0][0]}:#{m["data"]["signedData"]["author"][0][1]}" unless authorEmail
      m["authorGravatar"] = getGravatarHash(authorEmail)
      if gravatarForRecipient
        recipientEmail = m["recipientEmail"] if (m["recipientEmail"] and not m["recipientEmail"].empty?)
        recipientEmail = "#{m["data"]["signedData"]["recipient"][0][0]}:#{m["data"]["signedData"]["recipient"][0][1]}" unless recipientEmail
        m["recipientGravatar"] = getGravatarHash(recipientEmail)
      end
      authors = m["data"]["signedData"]["author"]
      m["linkToAuthor"] = authors.find do |a|
	IdentifiRails::Application.config.trustPathableTypes.include? a[0]
      end
      m["linkToAuthor"] ||= authors[0]
      recipients = m["data"]["signedData"]["recipient"]
      m["linkToRecipient"] = recipients.find do |a|
	IdentifiRails::Application.config.trustPathableTypes.include? a[0]
      end
      m["linkToRecipient"] ||= recipients[0]
    end
  end
  
  def getGravatarHash(gravatarEmail)
    Digest::MD5.hexdigest(gravatarEmail)
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
