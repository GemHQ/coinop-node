
bitcoin = require "bitcoinjs-lib"
{HDNode, ECKey} = bitcoin
randomBytes = require 'randombytes'
bs58 = require 'bs58'
txUtils = require './transaction_utils'


module.exports = class MultiWallet

  NETWORKMAP = {
    testnet3: 'testnet',
    testnet: 'testnet',
    bitcoin_testnet: 'testnet',
    bitcoin: 'bitcoin',
    mainnet: 'bitcoin'
  }


  getNode = (arg, network) ->
    if arg instanceof HDNode
      arg
    else if typeof arg == 'string'
      HDNode.fromSeedHex(arg, bitcoin.networks[network])
    else
      throw Error("Unusable type #{typeof arg}")

  
  getPublicNode = (arg, network) ->
    if arg instanceof HDNode
      arg
    else if typeof arg == 'string'
      # The network can be derived from the Base58 encoded string
      HDNode.fromBase58(arg)
    else
      throw Error("Unusable type #{typeof arg}")


  @generate: (names, networkName = 'testnet') ->
    unless networkName of NETWORKMAP
      throw Error("Unknown network #{networkName}")

    # normalizes the network name for bitcoinjs-lib
    network = NETWORKMAP[networkName]
    # networkDeatils is an object that bitcoinjs-lib
    # needs to construct a HDNode
    networkDetails = bitcoin.networks[network]
    masters = {}
    for name in names
      seed = randomBytes(32)
      node = HDNode.fromSeedBuffer(seed, networkDetails)
      node.seed = seed
      masters[name] = node

    new @({private: masters, network})


  constructor: (options) ->
    @privateTrees = {}
    @publicTrees = {}
    @trees = {}
    if 'network' of options and options.network of NETWORKMAP
      # normalizes the network name for bitcoinjs-lib
      @network = NETWORKMAP[options.network]
    else
      # normalizes the network name for bitcoinjs-lib
      @network = NETWORKMAP['testnet']

    privateTrees = options.private
    unless privateTrees?
      throw Error("Must supply private")

    for name, arg of privateTrees
      @privateTrees[name] = @trees[name] = getNode(arg, @network)

    if 'public' of options
      for name, arg of options.public
        @publicTrees[name] = @trees[name] = getPublicNode(arg, @network)


  # Returns an array of encoded signatures
  prepareTransaction: (transactionContent, txb) ->
    txb = txb || new bitcoin.TransactionBuilder()
    {inputs, outputs} = transactionContent

    @addInputs(inputs, txb)
    @addOutputs(outputs, txb)

    paths = txUtils.getPathsForInputs(inputs)

    signatures = @signAllInputs(paths, txb)
    encodedSignatures = @encodeSignatures(signatures)

    {
      signatures: encodedSignatures,
      
      txHash: txb.tx.getHash().toString('hex')
    }


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


  # A path is an array of indices, ex: [44,1,0,0,0]
  getPubKeysForPath: (path) ->
    trees = trees
    
    masterNodes = ['backup', 'cosigner', 'primary'].map (nodeName) =>
      masterNode = @trees[nodeName]
      @deriveNodeForPath(masterNode, path)

    pubKeys = masterNodes.map (node) ->
      node.pubKey


  # Fix: only works for primary
        # only works for 2/3 signatures
  # A path is an array of indices, ex: [44,1,0,0,0]
  getPrivKeyForPath: (path) ->
    primaryMasterNode = @privateTrees.primary
    primaryChildNode = @deriveNodeForPath(primaryMasterNode, path)
    privKey = primaryChildNode.privKey


  createRedeemScript: (pubKeys, numberOfSigs=2) ->
    bitcoin.scripts.multisigOutput(numberOfSigs, pubKeys)

    
  # A path is an array of indices, ex: [44,1,0,0,0]
  deriveNodeForPath: (parent, path) ->
    node = parent

    path.forEach (index) ->
      node = node.derive(index)

    return node


  # Fix: Expects only one signature per input
       # Only expect primary key to sign
       # This works for 2/3 multisig
  # returns an array of bae58-encoded signatures
  signAllInputs: (paths, txb) ->
    signatures = []
    {inputs} = txb

    inputs.forEach (input, index) =>
      path = paths[index]
      pubKeys = @getPubKeysForPath(path)
      privKey = @getPrivKeyForPath(path)
      redeemScript = @createRedeemScript(pubKeys)

      txb.sign(index, privKey, redeemScript)
      # bitcoinjs knows that we have a 2/3 signing scheme, so it populates 2 slots
      # in the signatures array with undefined.
      signature = txb.inputs[index].signatures.filter((sig) ->
        sig != undefined
      )[0]
      signatures.push(signature)

    return signatures


  encodeSignature: (signature, hashType = 1) ->
    bs58.encode signature.toScriptSignature(hashType)


  encodeSignatures: (signatures) ->
    encodedSignatures = signatures.map (signature) =>
      @encodeSignature(signature)



