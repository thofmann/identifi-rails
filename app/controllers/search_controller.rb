require 'identifi-rpc'

class SearchController < ApplicationController
  RESULT_COUNT = 15
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @nodeID = IdentifiRails::Application.config.nodeID
    offset = (params[:page].to_i * RESULT_COUNT) or 0
    @results = []
    if current_user
      @results = h.search(params[:query] || "", "", RESULT_COUNT.to_s, offset.to_s, current_user.type, current_user.value);
    else
      @results = h.search(params[:query] || "", "", RESULT_COUNT.to_s, offset.to_s, @nodeID[0], @nodeID[1]);
    end
    @results.each do |r|
      if r["email"].empty?
        gravatar = "#{r["type"]}:#{r["value"]}"
      else
        gravatar = r["email"]
      end
      r["gravatarHash"] = getGravatarHash(gravatar)
    end
    respond_to do |format|
      format.html
      format.json { render :json => @results }
    end
  end
end
