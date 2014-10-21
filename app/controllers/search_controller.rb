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
      result = {"type" => r[0][0], "value" => r[0][1], "email" => "", "name" => "", "nickname" => ""}
      r.each do |id|
          case id[0]
          when "name"
            result["name"] = id[1]
          when "nickname"
            result["nickname"] = id[1]
            result["name"] = id[1] if result["name"].empty?
          when "email"
            if ["name","nickname"].include? result["type"]
              result["type"] = id[0]
              result["value"] = id[1]
            end
            result["email"] = id[1]
          when "url"
            if ["name","nickname"].include? result["type"]
              result["type"] = id[0]
              result["value"] = id[1]
            end
            result["facebook"] = id[1].split("facebook.com/").last if id[1].include? "facebook.com/"
            result["twitter"] = id[1].split("twitter.com/").last if id[1].include? "twitter.com/"
            if id[1].include? "plus.google.com/+"
              result["google_plus"] = id[1].split("plus.google.com/+").last
            elsif id[1].include? "plus.google.com/"
              result["google_plus"] = id[1].split("plus.google.com/").last
            end
          when "bitcoin", "bitcoin_address"
            result["bitcoin"] = id[1]
          end
      end
      if ["name","nickname"].include? result["type"]
        if result["twitter"]
          result["type"] = "url"
          result["value"] = result["twitter"]
        elsif result["facebook"]
          result["type"] = "url"
          result["value"] = result["facebook"]
        elsif result["google_plus"]
          result["type"] = "url"
          result["value"] = result["google_plus"]
        end
      end
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
