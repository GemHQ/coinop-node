fs = require "fs"
assert = require "assert"
Testify = require "testify"

{crypto: {PassphraseBox}} = require "../../src/index"

yaml = require "js-yaml"

string = fs.readFileSync "test/data/passphrase_box_vectors.yaml"
vectors = yaml.safeLoad(string)


Testify.test "PassphraseBox", (context) ->

  context.test "test vectors", ->
    for vector in vectors
      plaintext = PassphraseBox.decrypt(vector.passphrase, vector)
      assert.equal plaintext, vector.plaintext

  context.test "internal round trip", ->
    plaintext = """
      I am not a number. I am a free man.
    """
    encrypted = PassphraseBox.encrypt "passphrase", plaintext

    recovered = PassphraseBox.decrypt "passphrase", encrypted
    assert.equal recovered, plaintext

