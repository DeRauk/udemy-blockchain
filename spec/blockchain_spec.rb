require 'blockchain/blockchain'
require 'util/crypto_hash'
require 'date'

describe Blockchain do
  let(:blockchain) { Blockchain.new }
  let(:new_chain) { Blockchain.new }
  let(:original_chain) { blockchain.chain }

  it 'contains a `chain` Array instance' do
    expect(blockchain.chain).to be_a(Array)
  end

  it 'starts with the genesis block' do
    expect(blockchain.chain[0]).to eq(Block.genesis)
  end

  it 'adds a new block to the chain' do
    newData = 'foo bar'
    blockchain.add(newData)
    expect(blockchain.last.data).to eq(newData)
  end

  describe '#isValidChain' do
    context 'when the chain does not start with the genesis block' do
      it 'returns false' do
        blockchain.chain[0] = { data: 'fake-genesis' }
        expect(Blockchain.isValidChain(blockchain.chain)).to eq(false)
      end
    end

    context 'when the chain does start with the genesis block and there are multiple blocks' do
      
      before do
        blockchain.add('Bears')
        blockchain.add('Beets')
        blockchain.add('Battlestar Galactica')
      end
      
      context 'and a last_hash reference is invalid' do
        it 'returns false' do
          blockchain.chain[2].last_hash = 'broken-last_hash'
          expect(Blockchain.isValidChain(blockchain.chain)).to eq(false)
        end
      end

      context 'and the chain contains a block with an invalid field' do
        it 'returns false' do
          blockchain.chain[2].data = 'some-bad-data'
          expect(Blockchain.isValidChain(blockchain.chain)).to eq(false)
        end

        context 'and the chain does not contain any invalid blocks' do
          it 'returns true' do
            expect(Blockchain.isValidChain(blockchain.chain)).to eq(true)
          end
        end
      end

      context 'and the chain contains a block with a jumped difficulty' do
        it 'returns false' do
          last_block = blockchain.last
          last_hash = last_block.hash

          timestamp = Time.now.to_i
          nonce = 0
          data = []
          difficulty = last_block.difficulty - 3

          hash = Crypto::hash(timestamp, last_hash, difficulty, nonce, data)
          bad_block = Block.new(
            timestamp: timestamp,
            last_hash: last_hash,
            hash: hash,
            data: data,
            nonce: nonce,
            difficulty: difficulty)
          blockchain.chain << bad_block

          expect(Blockchain.isValidChain(blockchain.chain)).to eq(false)
        end
      end
    end
  end

  describe '.replace_chain' do

    context 'when the chain is not longer' do
      it 'does not replace the chain' do
        new_chain.chain[2].hash = 'some-fake-hash'
        blockchain.replace_chain(new_chain.chain);
        expect(blockchain.chain).to eq(original_chain)
      end
    end

    context 'when the chain is longer'
    before do
      new_chain.add('Bears')
      new_chain.add('Beets')
      new_chain.add('Battlestar Galactica')
    end

    context 'and the chain is invalid' do
      it 'does not replace the chain' do
        new_chain.chain[2].hash = 'some-fake-hash'
        blockchain.replace_chain(new_chain.chain)
        expect(blockchain.chain).to eq(original_chain)
      end
    end

    context 'and the chain is valid' do
      it 'replaces the chain' do
        blockchain.replace_chain(new_chain.chain);
        expect(blockchain.chain).to eq(new_chain.chain)
      end
    end
  end

  describe '#serialize' do

    before do
      blockchain.add('Bears')
      blockchain.add('Beets')
      blockchain.add('Battlestar Galactica')
    end

    it 'serializes and unserializes correctly' do
      serialized = blockchain.serialize()
      unserialized = Blockchain.from_json(serialized)

      puts
      puts "Original: #{blockchain.chain}"
      puts "Unserialized: #{unserialized.chain}"

      expect(unserialized).to eq(blockchain)
    end
  end
end
