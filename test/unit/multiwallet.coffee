
bitcoin = require 'bitcoinjs-lib'
{HDNode, ECKey} = bitcoin
bs58check = require 'bs58check'

MultiWallet = require '../../src/bit/multiwallet'

transaction_data = require '../data/transaction.json'
{base58_seeds} = transaction_data
{payment_resource} = transaction_data

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


describe "Constructor", ->
  
  multiwallet = null

  before () ->
    multiwallet = new MultiWallet {
      private: {
        primary: base58_seeds.primary
      }
      public: {
        backup: base58_seeds.backup
        cosigner: base58_seeds.cosigner
      }
    }


  it 'should have prublicTrees, privateTrees, and trees properties', ->
    expect(multiwallet).to.have.a.property('publicTrees')
    expect(multiwallet).to.have.a.property('privateTrees')
    expect(multiwallet).to.have.a.property('trees')


  it 'should create HDNodes for all seeds', ->
    primaryNode = multiwallet.privateTrees.primary
    backupNode = multiwallet.publicTrees.backup
    cosignerNode = multiwallet.publicTrees.cosigner

    expect(primaryNode).to.be.an.instanceof(HDNode)
    expect(backupNode).to.be.an.instanceof(HDNode)
    expect(cosignerNode).to.be.an.instanceof(HDNode)


  it 'should throw an error when no private seed is provided', ->
    createMultiWallet = -> new MultiWallet({})
    expect(createMultiWallet).to.throw(Error)


  it 'should not throw an error if no public seeds are provided', ->
    createMultiWallet = -> new MultiWallet ({
      private: {
        primary: base58_seeds.primary
      }
    })
    expect(createMultiWallet).to.not.throw(Error)


describe 'transaction Preperation', ->

  multiwallet = null

  beforeEach () ->
    multiwallet = new MultiWallet {
      private: {
        primary: base58_seeds.primary
      }
      public: {
        backup: base58_seeds.backup
        cosigner: base58_seeds.cosigner
      }
    }


  describe 'addInputs', ->
    it 'should add every input to the provided transaction object', ->
      txb = new bitcoin.TransactionBuilder()
      {inputs} = payment_resource
      multiwallet.addInputs(inputs, txb)

      expect(txb.tx.ins).to.have.length(inputs.length)


    it 'should add teh right index for each input', ->
      txb = new bitcoin.TransactionBuilder()
      {inputs} = payment_resource
      multiwallet.addInputs(inputs, txb)

      inputs.forEach (input, i) ->
        indexFromResource = input.output.index
        indexFromTx = txb.tx.ins[i].index

        expect(indexFromResource).to.equal(indexFromTx)


    it 'should add the right prevOutScript for each input', ->
      txb = new bitcoin.TransactionBuilder()
      {inputs} = payment_resource
      multiwallet.addInputs(inputs, txb)

      inputs.forEach (input, i) ->
        scriptFromResource = input.output.script.string
        scriptFromTX = txb.prevOutScripts[i.toString()]

        expect(scriptFromResource).to.equal(scriptFromTX.toASM())


  describe "addOutputs", ->
    
    it "should add every output to the provided transaction object", ->
      txb = new bitcoin.TransactionBuilder()
      {outputs} = payment_resource
      multiwallet.addOutputs(outputs, txb)

      expect(txb.tx.outs).to.have.length(outputs.length)


    it "should add the right value for each output", ->
      txb = new bitcoin.TransactionBuilder()
      {outputs} = payment_resource
      multiwallet.addOutputs(outputs, txb)

      outputs.forEach (output, i) ->
        valueFromResource = output.value
        valueFromTx = txb.tx.outs[i].value
        expect(valueFromResource).to.equal(valueFromTx)


    it "should add the right script for each output", ->
      txb = new bitcoin.TransactionBuilder()
      {outputs} = payment_resource
      multiwallet.addOutputs(outputs, txb)

      outputs.forEach (output, i) ->
        scriptFromResource = output.script.string
        scriptFromTx = txb.tx.outs[i].script.toASM()
        
        expect(scriptFromResource).to.have.a.equal(scriptFromTx)


  describe "parsePath", ->

    it "should return an array of indices", ->
      indices = multiwallet.parsePath('m/44/1/0/0/0')

      expect(indices).to.deep.equal([44,1,0,0,0])


  describe "getPathForInput", ->

    it "should return the path from the given input index", ->
      {inputs} = payment_resource

      inputs.forEach (input, i) ->
        path = multiwallet.getPathForInput(payment_resource, i)
        expect(path).to.equal(inputs[i].output.metadata.wallet_path)


  describe "deriveNodeForIndices", ->

    it 'should derive the correct child node', ->
      indices = [44,1,0,0,0]
      derived_primary_seed = transaction_data.base58_derived_seeds.primary
      primaryMasterNode = multiwallet.trees.primary
      derivedPrimaryNode = multiwallet.deriveNodeForIndices(primaryMasterNode, indices)
      derivedPrimarySeed = derivedPrimaryNode.toBase58()

      expect(derived_primary_seed).to.equal(derivedPrimarySeed)
        

  describe "getPubKeysForPath", ->

    it "should derive the correct pubKeys for a given path", ->
      {derived_pubkeys_hex} = transaction_data
      {backup, cosigner, primary} = derived_pubkeys_hex
      derivedpubKeys = multiwallet.getPubKeysForPath("m/44/1/0/0/0")
      derivedpubKeysHex = derivedpubKeys.map (node) -> node.toHex()

      expect([backup, cosigner, primary]).to.deep.equal(derivedpubKeysHex)
      

  describe.only "createRedeemScript", ->

    it "should contain hex of all provided pubkeys", ->
      {derived_pubkeys_hex} = transaction_data
      pubKeys = multiwallet.getPubKeysForPath("m/44/1/0/0/0")
      redeemScript = multiwallet.createRedeemScript(pubKeys)
        .toASM()

      for own name, pubKey of derived_pubkeys_hex
        expect(redeemScript).to.contain(pubKey)


    it "should contain OP_CHECKMULTISIG", ->
      pubKeys = multiwallet.getPubKeysForPath("m/44/1/0/0/0")
      redeemScript = multiwallet.createRedeemScript(pubKeys)
        .toASM()
      
      expect(redeemScript).to.contain("OP_CHECKMULTISIG")




  describe.only "payment.sign", ->

    it "should generate the same hash for the same tx", ->
      {inputs, outputs} = payment_resource
      txb = new bitcoin.TransactionBuilder()
      # utility
      multiwallet.addInputs(inputs, txb)
      multiwallet.addOutputs(outputs, txb)
      
      path = multiwallet.getPathForInput(payment_resource ,0)
      
      pubKeys = multiwallet.getPubKeysForPath(path)
      privKey = multiwallet.getPrivKeyForPath(path)
      # utility
      redeemScript = multiwallet.createRedeemScript(pubKeys)

      sig = txb.sign(0, privKey, redeemScript)
      sig2 = txb.signatures[0].signatures[0]
      
      console.log(bs58check.encode sig.toScriptSignature(1))
      console.log(bs58check.encode sig2.toScriptSignature(1))


















