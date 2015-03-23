crypto = require "crypto"
{Const, SecretBox, Key, Random} = require("sodium")

module.exports = class PassphraseBox

  ITERATIONS = 10000

  @encrypt: (passphrase, plaintext) ->
    box = new @({passphrase})
    box.encrypt(plaintext)


  @decrypt: (passphrase, encrypted) ->
    {salt, iterations, nonce, ciphertext} = encrypted
    box = new @({passphrase, salt, iterations})
    box.decrypt(ciphertext, nonce)


  constructor: ({passphrase, salt, @iterations}) ->
    if salt
      @salt = new Buffer(salt, "hex")
    else
      @salt = new Buffer(16)
      Random.buffer(@salt)

    @iterations ?= ITERATIONS

    buffer = crypto.pbkdf2Sync(passphrase, @salt, @iterations, 32)
    key = new Key.SecretBox(buffer)

    @box = new SecretBox(key)


  encrypt: (plaintext) ->
    {cipherText, nonce} = @box.encrypt(plaintext, "utf8")
    # Strip 16 bytes of zero-padding, as the implementations
    # used in other languages do not include it.
    ciphertext = cipherText.slice(16)

    {
      iterations: @iterations
      salt: @salt.toString("hex")
      nonce: nonce.toString("hex")
      ciphertext: ciphertext.toString("hex")
    }


  decrypt: (ciphertext, nonce) ->
    # Replace the 16 bytes of zero-padding.
    ciphertext = "00000000000000000000000000000000" + ciphertext
    cipherText = new Buffer(ciphertext, "hex")
    nonce = new Buffer(nonce, "hex")
    plaintext = @box.decrypt {cipherText, nonce}, "utf8"
    throw new Error unless plaintext?
    plaintext

