class SearchController < ApplicationController
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @results = h.search(params[:query]);
    respond_to do |format|
      format.html
      format.json { render :json => @results }
    end
  end
end
