assert = require "assert"
Testify = require "testify"

{crypto: {PassphraseBox}} = require "../../src/index"

Testify.test "PassphraseBox", (context) ->

  context.test "no op", ->
    assert true

