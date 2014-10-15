require 'identifi-rpc'

class SearchController < ApplicationController
  RESULT_COUNT = 15
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @nodeID = IdentifiRails::Application.config.nodeID
    offset = (params[:page].to_i * RESULT_COUNT) or 0
    @results = []
    if current_user
      @rawResults = h.search(params[:query] || "", "", RESULT_COUNT.to_s, offset.to_s, current_user.type, current_user.value);
    else
      @rawResults = h.search(params[:query] || "", "", RESULT_COUNT.to_s, offset.to_s, @nodeID[0], @nodeID[1]);
    end
    @rawResults.each do |r|
      result = {"type" => "", "value" => "", "email" => "", "name" => ""}
      r.each do |id|
          case id[0]
          when "name" || "nickname"
            result["name"] = id[1]
          when "email"
            result["email"] = id[1]
          when "url"
            result["facebook"] = id[1] if id[1].include? "facebook.com/"
            result["twitter"] = id[1] if id[1].include? "twitter.com/"
            result["google_plus"] = id[1] if id[1].include? "plus.google.com/"
          end
      end
      result["type"] = r[0][0]
      result["value"] = r[0][1]
      if result["email"].empty?
        gravatar = "#{result["type"]}:#{result["value"]}"
      else
        gravatar = result["email"]
      end
      result["gravatarHash"] = getGravatarHash(gravatar)
      @results << result
    end
    respond_to do |format|
      format.html
      format.json { render :json => @results }
    end
  end
end
