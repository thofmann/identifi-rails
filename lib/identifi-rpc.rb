require 'net/http'
require 'uri'
require 'json'
 
class IdentifiRPC
  def initialize(service_url)
    @uri = URI.parse(service_url)
  end

  def delete_cached(name, args)
    Rails.cache.delete(get_post_body(name, args))
  end
 
  def method_missing(name, *args)
    post_body = get_post_body(name, args) 
    resp = JSON.parse( http_post_request(post_body) )
    raise JSONRPCError, resp['error'] if resp['error']
    resp['result']
  end
 
  def http_post_request(post_body)
    Rails.cache.fetch(post_body, :expires_in => IdentifiRails::Application.config.rpcCacheTime.seconds) do
      http    = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Post.new(@uri.request_uri)
      request.basic_auth @uri.user, @uri.password
      request.content_type = 'application/json'
      request.body = post_body
      http.request(request).body
    end
  end
 
  class JSONRPCError < RuntimeError; end

  private

  def get_post_body(name, args)
    { 'method' => name, 'params' => args, 'id' => 'jsonrpc' }.to_json
  end
end
