
bitcoin = require 'bitcoinjs-lib'
{HDNode, ECKey} = bitcoin
MultiWallet = require '../../src/bit/multiwallet'

expect = require('chai').expect


describe "MultiWallet from MultiWallet.generate", ->
  multiwallet = MultiWallet.generate(['primary', 'backup'], 'testnet')

  it "should generate return a MultiWallet", ->
    expect(multiwallet).to.be.an.instanceof(MultiWallet)

  it "should have a property @network", ->
    expect(multiwallet.network).to.equal('testnet')

  it "@privateTrees @trees should have properties 'primary' and 'backup'", ->
    expect(multiwallet.privateTrees).to.have.a.property('primary')
    expect(multiwallet.privateTrees).to.have.a.property('backup')
    expect(multiwallet.trees).to.have.a.property('primary')
    expect(multiwallet.trees).to.have.a.property('backup')

  it '@privateTrees.primary and @privateTrees.backup should be HDNodes', ->
    primary = multiwallet.privateTrees.primary
    backup = multiwallet.privateTrees.backup
    
    expect(primary).to.be.an.instanceof(HDNode)
    expect(backup).to.be.an.instanceof(HDNode)



