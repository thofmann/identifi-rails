require 'identifi-rpc'

class SearchController < ApplicationController
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @latest = h.getlatestpackets( "10" )
  end

  def search
  	"moi"
  end

end
