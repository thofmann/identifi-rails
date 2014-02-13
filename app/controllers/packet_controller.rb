require 'identifi-rpc'

class PacketController < ApplicationController
  def show
    h = IdentifiRPC.new(IdentifiRails::Application.config.identifiHost)
    @packet = h.getpacketbyhash( params[:hash] ).first
  end
end
