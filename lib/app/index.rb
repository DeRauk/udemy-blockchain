require 'json'
require 'sinatra'
require 'net/http'
require 'uri'
require 'app'
require 'blockchain/blockchain'
require 'pubsub'

blockchain = App.blockchain
pubsub = PubSub.new(blockchain)

PORT = 4567

get '/' do
  'Hello world!'
end

get '/api/blocks' do
  content_type :json
  blockchain.serialize
end

post '/api/mine' do
  request.body.rewind
  data = (JSON.parse request.body.read)["data"]
  blockchain.add(data)

  pubsub.broadcast_chain

  redirect '/api/blocks'
end

def sync_chains
  root_node_request = "http://localhost:#{PORT}/api/blocks"
  uri = URI(root_node_request)
  res = Net::HTTP.get_response(uri)
  
  root_chain = Blockchain.from_json(res.body)
  puts "Replace chain on a sync with #{root_chain.chain}"
  App.blockchain.replace_chain(root_chain.chain)
end

def server_up?
  begin
    uri = URI("http://localhost:#{PORT}/")
    res = Net::HTTP.get_response(uri)
  rescue Errno::ECONNREFUSED, Net::ReadTimeout => e
    return false
  end

  res.code == '200'
end

def startup
  port = PORT

  if ENV["GENERATE_PEER_PORT"] == 'true'
    port += rand(1...1000)
  end

  set :port, port

  Thread.new { 
    sleep(1) until server_up?
    sync_chains
  }
end

startup
