require 'json'
require 'redis'
require 'securerandom'
require 'blockchain/blockchain'
require 'config'

class PubSub
  attr_reader :id, :blockchain

  def initialize(blockchain)
    @blockchain = blockchain
    @publisher = Redis.new(:timeout => 5)
    @subscriber = Redis.new(:timeout => 5)
    @id = SecureRandom.uuid

    puts "Sender Id: #{id}"

    Thread.new { subscribe_to_channels }
  end

  def subscribe_to_channels
    channels = Config::CHANNELS.map { |x,v| v }

    puts "Subscribing to channels"

    subscriber.subscribe(channels) do |on|
      on.message do |channel,msg|
        puts "Received message"
        msg = JSON.parse(msg)
        
        if msg["sender_id"] != @id

          puts msg["data"]
          blockchain = Blockchain.from_dict(msg["data"])
          puts "Message received. Channel: #{channel}. Data: #{msg}"

          blockchain.replace_chain(blockchain.chain)
        end
      end
    end
  end

  def publish(channel, data)
    msg =
      {
        "data": data,
        "sender_id": id
      }

    publisher.publish(channel, msg.to_json)
    puts "Published Message"
  end

  def broadcast_chain
    publish(Config::CHANNELS[:BLOCKCHAIN], blockchain)
  end

  private
  attr_accessor :subscriber, :publisher

end
