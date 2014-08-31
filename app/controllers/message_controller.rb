require 'identifi-rpc'

class MessageController < ApplicationController
  def show
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @msg = h.getmsgbyhash( params[:hash] ).first
  end
end
