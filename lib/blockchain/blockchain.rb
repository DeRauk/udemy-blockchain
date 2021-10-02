require 'blockchain/block'
require 'util/crypto_hash'

class Blockchain
  attr_reader :chain

  def initialize()
    @chain = [Block.genesis]
  end

  def add(data)
    newBlock = Block.mine(last_block: self.last, data: data)
    self.chain << newBlock
  end

  def last
    chain[-1]
  end

  def ==(other)
    chain.each_with_index do |block, index|
      return false unless chain[index] == other.chain[index]
    end
  end

  def replace_chain(new_chain)
    return unless new_chain.length > @chain.length

    @chain = new_chain
  end

  def as_json(options={})
    {
      chain: chain
    }
  end

  def to_json(*options)
    as_json(*options).to_json(*options)
  end

  def from_json(data)
    dict = JSON.parse data
    from_dict(dict)
  end

  def from_dict(dict)
    dict["chain"].drop(1).each do |block_hash|
      chain << Block.from_dict(block_hash)
    end
  end

  def serialize
    self.to_json
  end

  def self.isValidChain(chain)
    # The genesis block must be first
    return false unless chain[0] == Block.genesis

    for i in 1...chain.length do
      this_block = chain[i]
      prev_block = chain[i-1]
      last_difficulty = prev_block.difficulty

      # The current block's last_hash value must be equal the the previous block's hash
      return false unless this_block.last_hash == prev_block.hash

      # The current block's hash must be accurate
      return false unless this_block.hash == Crypto::hash(this_block.timestamp, this_block.last_hash, this_block.data, this_block.nonce, this_block.difficulty)

      return false if (last_difficulty - this_block.difficulty).abs() > 1
    end

    return true
  end

  def self.from_json(data)
    blockchain = Blockchain.new
    blockchain.from_json(data)
    blockchain
  end

  def self.from_dict(data)
    blockchain = Blockchain.new
    blockchain.from_dict(data)
    blockchain
  end
end
