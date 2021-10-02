require 'date'
require 'json'
require 'config'
require 'util/crypto_hash'
require 'util/hex_to_binary'

class Block
  attr_accessor :timestamp, :last_hash, :hash, :data, :nonce, :difficulty

  def initialize(timestamp:, last_hash:, hash:, data:, nonce:, difficulty:)
    @timestamp = timestamp
    @last_hash = last_hash
    @hash = hash
    @data = data
    @nonce = nonce
    @difficulty = difficulty
  end

  def self.genesis
    return Block.new(**Config::GENESIS_DATA)
  end

  def ==(other)
    timestamp == other.timestamp &&
    last_hash == other.last_hash &&
    hash == other.hash &&
    data == other.data &&
    nonce == other.nonce &&
    difficulty == other.difficulty
  end

  def as_json(options={})
    {
      timestamp: timestamp,
      last_hash: last_hash,
      hash: hash,
      data: data,
      nonce: nonce,
      difficulty: difficulty,
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def self.adjust_difficulty(original_block, timestamp)
    difficulty = original_block.difficulty
    return 1 if difficulty < 1

    difference = timestamp - original_block.timestamp

    return difficulty - 1 if difference > Config::MINE_RATE

    return difficulty + 1
  end

  def self.from_dict(data)
    Block.new(
      timestamp: data['timestamp'],
      last_hash: data['last_hash'],
      hash: data['hash'],
      data: data['data'],
      nonce: data['nonce'],
      difficulty: data['difficulty']
    )
  end

  def self.mine(last_block:, data:)
    last_hash = last_block.hash
    difficulty = last_block.difficulty
    timestamp = Time.now.to_i
    nonce = 0
    hash = Crypto::hash(timestamp, last_hash, data, nonce, difficulty);

    loop do
      nonce += 1
      timestamp = Time.now.to_i
      difficulty = Block.adjust_difficulty(last_block, timestamp)
      hash = Crypto::hash(timestamp, last_hash, data, nonce, difficulty)
      binary_hash = Helper::hex_to_binary(hash)
      break if binary_hash[1...difficulty+1] == '0' * difficulty # TODO why is the first bit always 1??
    end

    Block.new(
      timestamp: timestamp,
      last_hash: last_hash,
      hash: hash,
      data: data,
      nonce: nonce,
      difficulty: difficulty
      )
  end
end
