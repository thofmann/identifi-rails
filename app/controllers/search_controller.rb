class SearchController < ApplicationController
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @nodeID = IdentifiRails::Application.config.nodeID
    if current_user
      @results = h.search(params[:query], "", "5", "0", current_user.type, current_user.value);
    else
      @results = h.search(params[:query], "", "5", "0", @nodeID[0], @nodeID[1]);
    end
    respond_to do |format|
      format.html
      format.json { render :json => @results }
    end
  end
end
