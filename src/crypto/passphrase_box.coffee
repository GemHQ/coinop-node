crypto = require "crypto"

module.exports = class PassphraseBox

  ITERATIONS = 100000

  @encrypt: (passphrase, plaintext, callback) ->
    box = new @({passphrase})
    box.encrypt(plaintext)


  @decrypt: (passphrase, encrypted, callback) ->
    {salt, iterations, nonce, ciphertext} = encrypted
    box = new @({passphrase, salt, iterations})
    box.decrypt(ciphertext, nonce)


  constructor: ({passphrase, salt, @iterations}, callback) ->
    if salt
      @salt = new Buffer(salt, "hex")
    else
      try 
        @salt = crypto.randomBytes(16)
      catch
        throw new Error("Error generating random bytes")

    @iterations ?= ITERATIONS

    crypto.pbkdf2Sync(passphrase, @salt, @iterations, 64, (error, buffer) =>
      return callback(error) if error

      @aes_key = buffer.slice(0,32)
      @hmac_key = buffer.slice(32,64)


  encrypt: (plaintext, nonce) ->
    # {cipherText, nonce} = @box.encrypt(plaintext, "utf8")
    # # Strip 16 bytes of zero-padding, as the implementations
    # # used in other languages do not include it.
    # ciphertext = cipherText.slice(16)
    try
      nonce ?= crypto.randomBytes(16)
    catch
      throw new Error("Error generating random bytes")

    encrypted = crypto.createCipheriv('aes-256-cbc', @aes_key, nonce)
      .update(plaintext, 'utf8')
      .final()

    hash = crypto.createHMAC('sha256', @hmac_key)
      .update(Buffer.concat([nonce, encrypted]))
      .digest()
    
    ciphertext = Buffer.concat([encrypted, hash])

    {
      iterations: @iterations
      salt: @salt.toString("hex")
      nonce: nonce.toString("hex")
      ciphertext: ciphertext.toString("hex")
    }


  decrypt: (ciphertext, nonce) ->
    # Replace the 16 bytes of zero-padding.
    # ciphertext = "00000000000000000000000000000000" + ciphertext
    # cipherText = new Buffer(ciphertext, "hex")
    # nonce = new Buffer(nonce, "hex")
    # plaintext = @box.decrypt {cipherText, nonce}, "utf8"
    # throw new Error unless plaintext?
    # plaintext
    ciphertext = new Buffer(ciphertext, 'hex')
    nonce = new Buffer(nonce, 'hex')
    mac = ciphertext.slice(0, 32)
    ciphertext = ciphertext.slice(32, 64)
    hmac = createHMAC('sha256', @hmac_key)
      .update(Buffer.concat([nonce, ciphertext]))

    if hmac.digest().toString('hex') != mac.toString('hex')
      throw new Error('Invalid authentication code - this
                       ciphertext may have been tampered with')

    aes = crypto.createDecipheriv('aes-256-cbc', @aes_key, nonce)
      .update(ciphertext, 'utf8')
      .final('utf8')




