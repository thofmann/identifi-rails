require 'identifi-rpc'

class SearchController < ApplicationController
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @latest = h.getpacketsafter( "0", "20" )
  end
end
