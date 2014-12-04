
bitcoin = require "bitcoinjs-lib"
PassphraseBox = require "../crypto/passphrase_box"
{HDNode, ECKey} = bitcoin


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
      chainCode = new Buffer(32)
      chainCode.fill(1)
      keyPair = ECKey.makeRandom()
      privkey = keyPair.d
      # the bitcoin library requires an object from their
      # library in order to set the network
      networkDetails = bitcoin.networks[network]
      masters[name] = new HDNode(privkey, chainCode, networkDetails)

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




