
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

    if 'public' of options
      for name, arg of options.public
        @publicTrees[name] = @trees[name] = getNode(arg)


  addInputs: (inputs, transactionBuilder) ->
    inputs.forEach (input) ->
      prevTx = input.output.transaction_hash
      index = input.output.index
      ASM = input.output.script.string
      prevOutScript = bitcoin.Script.fromASM(ASM)

      transactionBuilder.addInput(prevTx, index, undefined, prevOutScript)


  addOutputs: (outputs, transactionBuilder) ->
    outputs.forEach (output) ->
      ASM = output.script.string
      scriptPubKey = bitcoin.Script.fromASM(ASM)
      value = output.value

      transactionBuilder.addOutput(scriptPubKey, value)


  getPubKeysForPath: (path) ->
    indices = @parsePath(path)
    trees = trees
    
    masterNodes = ['backup', 'cosigner', 'primary'].map (nodeName) =>
      masterNode = @trees[nodeName]
      @deriveNodeForIndices(masterNode, indices)

    pubKeys = masterNodes.map (node) ->
      node.pubKey


  getPrivKeyForPath: (path) ->
    indices = @parsePath(path)
    primaryMasterNode = @privateTrees.primary
    primaryChildNode = @deriveNodeForIndices(primaryMasterNode, indices)
    privKey = primaryChildNode.privKey


  createRedeemScript: (pubKeys, numberOfSigs=2) ->
    bitcoin.scripts.multisigOutput(numberOfSigs, pubKeys)


  # should be a private method
  # not sure how to test though
  parsePath: (path) ->
    parts = path.split('/')
    # removes "m" from parts
    indices = parts.slice(1).map (index) ->
      # converts index to a number
      +index


  # should be a private method
  # not sure how to test though
  getPathForInput: (paymentResource, index) ->
    path = paymentResource.inputs[index].output.metadata.wallet_path
    

  # should be a private method
  # not sure how to test though
  deriveNodeForIndices: (parent, indices) ->
    node = parent

    indices.forEach (index) ->
      node = node.derive(index)

    return node







