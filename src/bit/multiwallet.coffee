
bitcoin = require "bitcoinjs-lib"
{HDNode, ECKey} = bitcoin
PassphraseBox = require "../crypto/passphrase_box"
crypto = require 'crypto'



module.exports = class MultiWallet

  NETWORKMAP = {
    testnet3: 'testnet',
    testnet: 'testnet',
    bitcoin_testnet: 'testnet',
    bitcoin: 'bitcoin'
  }

  getNode = (arg) ->
    if arg instanceof HDNode
      arg
    else if typeof arg == 'string'
      HDNode.fromBase58(arg)
    else
      throw Error("Unusable type #{typeof arg}")

  @generate: (names, networkName = 'testnet') ->
    unless networkName of NETWORKMAP
      throw Error("Unknown network #{networkName}")

    network = NETWORKMAP[networkName]
    masters = {}
    for name in names
      seed = crypto.randomBytes(32)
      networkDetails = bitcoin.networks[network]
      node = HDNode.fromSeedBuffer(seed, networkDetails)
      masters[name] = node

    new @({private: masters, network})


  constructor: (options) ->
    @privateTrees = {}
    @publicTrees = {}
    @trees = {}
    if 'network' of options and options.network of NETWORKMAP
      @network = NETWORKMAP[options.network]
    else
      @network = NETWORKMAP['testnet']

    privateTrees = options.private
    unless privateTrees?
      throw Error("Must supply private")

    for name, arg of privateTrees
      @privateTrees[name] = @trees[name] = getNode(arg)

    if 'public' in options
      for name, arg of options.public
        @publicTrees[name] = @trees[name] = getNode(arg)
        