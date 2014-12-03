
bitcoin = require "bitcoinjs-lib"
PassphraseBox = require "../crypto/passphrase_box"
{HDNode, ECKey} = bitcoin





class MultiWallet

  getNode = (arg) ->
    if arg instanceof HDNode
      arg
    # still working on this part
    else if typeof arg == 'string'
      return "This is not done yet"

  NETWORKMAP = {
    testnet3: 'testnet',
    bitcoin_testnet: 'testnet',
    bitcoin: 'bitcoin'
  }


  @generate: (names, networkName = 'testnet3') ->
    unless networkName of NETWORKMAP
      throw Error("Unknown network #{networkName}")

    network = NETWORKMAP[networkName]
    masters = {}
    for name in names
      chainCode = new Buffer(32)
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
      @network = options.network
    else
      @network ='testnet3'

    privateTrees = options.private
    unless privateTrees?
      throw Error("Must supply private")

    for name, arg of privateTrees
      @privateTrees[name] = @trees[name] = getNode(arg)

    # FIXME: not sure how to do this yet
    # if 'public' in options
    #   for name, arg of options.public
    #     @publicTrees[name] = @trees[name] = getNode(arg)


module.exports = MultiWallet

# create = (email, passphrase, callback) ->
#   multiwallet = MultiWallet.generate(['primary', 'backup'])
#   network = 'bitcoin_testnet'
#   primarySeed = multiwallet.trees.primary.toBase58()
#   encryptedSeed = PassphraseBox.encrypt(passphrase, primarySeed)
#   wallet = {
#     network,
#     backup_public_seed: multiwallet.trees.backup.neutered().toBase58()
#     primary_public_seed: multiwallet.trees.primary.neutered().toBase58()
#     primary_private_seed: encryptedSeed
#   }

#   params = {email, wallet}
#   @resource.create params, (error, userResource) ->
#     return callback(error) if error

#     return {
#       multiwallet,
#       new User(userResource, @client())
#     }


create('bez@gmail.com', 'passphrase')


