module Config
  MINE_RATE = 1000
  INITIAL_DIFFICULTY = 3

  CHANNELS =
    {
      "TEST": 'TEST',
      "BLOCKCHAIN": 'BLOCKCHAIN'
    }.freeze

  GENESIS_DATA =
    {
      timestamp: 1,
      last_hash: '-----',
      hash: 'hash-one',
      data: [],
      nonce: 0,
      difficulty: INITIAL_DIFFICULTY
    }.freeze
end
