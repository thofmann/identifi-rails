class SearchController < ApplicationController
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @results = h.search(params[:query]);
  end
end
