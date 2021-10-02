require 'blockchain/block'
require './config'
require 'util/crypto_hash'

describe Block do
  let(:timestamp) { 2000 }
  let(:last_hash) { 'foo-hash' }
  let(:hash) { 'bar-hash' }
  let(:data) { ['blockchain', 'data'] }
  let(:nonce) { 1 }
  let(:difficulty) { 1 }
  let(:block) { 
    Block.new(
      timestamp: timestamp,
      last_hash: last_hash,
      hash: hash,
      data: data,
      nonce: nonce,
      difficulty: difficulty
      )}

  it 'has a timestamp, last_hash, hash, and data property' do
    expect(block.timestamp).to eq(timestamp)
    expect(block.last_hash).to eq(last_hash)
    expect(block.hash).to eq(hash)
    expect(block.data).to eq(data)
  end

  describe '#genesis' do
    let(:genesisBlock) { Block.genesis }

    it 'returns a Block instance' do
      expect(genesisBlock).to be_a(Block)
    end

    it 'returns the genesis data' do
      expect(genesisBlock.timestamp).to eq(Config::GENESIS_DATA[:timestamp])
      expect(genesisBlock.last_hash).to eq(Config::GENESIS_DATA[:last_hash])
      expect(genesisBlock.hash).to eq(Config::GENESIS_DATA[:hash])
      expect(genesisBlock.data).to eq(Config::GENESIS_DATA[:data])
    end
  end

  describe '#mine' do
    let(:last_block) { Block.genesis }
    let(:data) { 'mined data' }
    let(:minedBlock) { Block.mine(last_block: last_block, data: data)}

    it 'it returns a Block instance' do
      puts "mined block: #{minedBlock.class}"
      expect(minedBlock).to be_a(Block)
    end

    it 'sets the `last_hash` to be the `hash` of the last_block' do
      expect(minedBlock.last_hash).to eq(last_block.hash)
    end

    it 'sets the `data`' do
      expect(minedBlock.data).to eq(data)
    end

    it 'sets a `timestamp`' do
      expect(minedBlock.timestamp).not_to eq(nil)
    end

    it 'creates a sha256 hash based on the proper inputs' do
      expect(minedBlock.hash).to eq(
        Crypto::hash(
          minedBlock.timestamp,
          last_block.hash,
          data,
          minedBlock.nonce,
          minedBlock.difficulty
          ))
    end

    it 'sets a hash that matches the difficulty criteria' do
      expect(Helper::hex_to_binary(minedBlock.hash)[1...minedBlock.difficulty+1]).to eq("0" * minedBlock.difficulty)
    end

    it 'adjusts the difficulty' do
      possible_results = [last_block.difficulty+1, last_block.difficulty-1]
      expect(possible_results).to include(minedBlock.difficulty)
    end

  end

  describe "#adjust_difficulty" do
    it 'raises the difficulty for a quickly mined block' do
      puts block.timestamp.class
      expect(Block.adjust_difficulty(block, block.timestamp + Rational(Config::MINE_RATE - 100, 86400))).to eq(block.difficulty+1)
    end

    it 'lowers the difficulty for a slowly mined block' do
    end

    it 'has a lower limit of 1' do
    end

  end
end
