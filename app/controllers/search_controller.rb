require 'identifi-rpc'

class SearchController < ApplicationController
  MSG_COUNT = 10
  def index
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    offset = (params[:page].to_i * MSG_COUNT) or 0
    @latest = h.getlatestpackets( MSG_COUNT.to_s, offset.to_s )
  end
end
