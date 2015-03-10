
txUtils = require '../../src/bit/transaction_utils'

transaction_data = require '../data/transaction.json'
{payment_resource} = transaction_data

expect = require('chai').expect




describe "getPathsForInputs", ->

  it "should return an array of paths", ->
    {inputs} = payment_resource
    paths = txUtils.getPathsForInputs(inputs)

    expect(paths).to.deep.equal([[44,1,0,0,0]])



describe "getPathForInput", ->

  it "should return the path from the given input index", ->
    {inputs} = payment_resource

    inputs.forEach (input, i) ->
      path = txUtils.getPathForInput(payment_resource, i)
      pathFromResource = txUtils.parsePath(inputs[i].output.metadata.wallet_path)
      
      expect(path).to.deep.equal(pathFromResource)



describe "parsePath", ->

  it "should return an array of indices", ->
    parsedPath = txUtils.parsePath('m/44/1/0/0/0')

    expect(parsedPath).to.deep.equal([44,1,0,0,0])


