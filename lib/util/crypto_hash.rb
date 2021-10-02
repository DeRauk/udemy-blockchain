require 'digest'

module Crypto
  def self.hash(*inputs)
    strings = inputs.map{ |v| v.to_s }.sort
    Digest::SHA256.hexdigest(strings.join(' '))
  end
end
