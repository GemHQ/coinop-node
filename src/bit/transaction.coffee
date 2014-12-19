
bitcoin = require 'bitcoinjs-lib'

module.exports = class Transaction

  @data: (data) ->
    {version, lock_time, fee, inputs, outputs, confirmations} = data
    transaction = new @({fee, version, lock_time, confirmations})

    data.forEach (data) ->
      # FIXME: create Output class
      # FIXME: write addOutput
      transaction.addOutput(new Output(data))

    if inputs?
      inputs.forEach (data, index) ->
        # FIXME: write inOutput
        transaction.addInput data

    ## FIXME: verify that the supplied and computed sig_hashes match
    #puts :sig_hashes_match => (data[:sig_hash] == input.sig_hash)

    transaction


  constructor: (options={}) ->
    @native = new bitcoin.TransactionBuilder()
    @inputs = []
    @outputs = []
    @desiredFee = options.fee if options.fee
    @confirmations = options.confirmations if options.confirmations


  addInput: (input) ->
    unless input instanceof Input
      # FIXME: create input class
      input.transaction = @
      input.index = @inputs.length
      input = new Input(input)

    @inputs.push(input)
    @native.addInput()












