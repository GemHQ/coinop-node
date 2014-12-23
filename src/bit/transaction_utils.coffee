
# Returns an array of paths
getPathsForInputs = (inputs) ->
  paths = inputs.map (input) ->
    path = input.output.metadata.wallet_path
    parsedPath = parsePath(path)


parsePath = (path) ->
  parts = path.split('/')
  # removes "m" from parts
  indices = parts.slice(1).map (index) ->
    # converts index to a number
    +index


# FixMe: chnage so that it only takes the input rather than a resource and index
getPathForInput = (paymentResource, index) ->
  path = paymentResource.inputs[index].output.metadata.wallet_path
  parsePath(path)



module.exports = {

  getPathsForInputs

  parsePath

  getPathForInput

}
