crypto = require "crypto"

module.exports = class AESBox

  ITERATIONS = 100000

  @encrypt: (passphrase, plaintext, callback) ->
    new @({passphrase}, (error, box) ->
      callback(error, box.encrypt(plaintext))
    )


  @decrypt: (passphrase, encrypted, callback) ->
    {salt, iterations, nonce, ciphertext} = encrypted
    new @({passphrase, salt, iterations}, (error, box) ->
      callback(error, box.decrypt(ciphertext, nonce))
    )


  constructor: ({passphrase, salt, @iterations}, callback) ->
    if salt
      @salt = new Buffer(salt, "hex")
    else
      try
        @salt = crypto.randomBytes(16)
      catch
        throw new Error("Error generating random bytes")

    @iterations ?= ITERATIONS

    crypto.pbkdf2(passphrase, @salt, @iterations, 64, (error, buffer) =>
      return callback(error) if error


      @aes_key = buffer.slice(0,32)
      @hmac_key = buffer.slice(32,64)
      callback(null, @)
    )


  encrypt: (plaintext, nonce) ->
    try
      nonce ?= crypto.randomBytes(16)
    catch
      throw new Error("Error generating random bytes")

    aes = crypto.createCipheriv('aes-256-cbc', @aes_key, nonce)
    encrypted = aes.update(plaintext, 'utf8')
    encrypted = Buffer.concat([encrypted, aes.final()])

    mac = crypto.createHmac('sha256', @hmac_key)
      .update(Buffer.concat([nonce, encrypted]))
      .digest()

    ciphertext = Buffer.concat([encrypted, mac])

    {
      iterations: @iterations
      salt: @salt.toString("hex")
      nonce: nonce.toString("hex")
      ciphertext: ciphertext.toString("hex")
    }


  decrypt: (cipherData, nonce) ->
    cipherDataBuf = new Buffer(cipherData, 'hex')
    nonceBuf = new Buffer(nonce, 'hex')
    ciphertext = cipherDataBuf.slice(0, -32)
    hmacOld = cipherDataBuf.slice(-32).toString('hex')
    hmacNew = crypto.createHmac('sha256', @hmac_key)
      .update(Buffer.concat([nonceBuf, ciphertext]))
      .digest()
      .toString('hex')

    if hmacOld != hmacNew
      throw new Error('Invalid authentication code - this
                       ciphertext may have been tampered with')

    aes = crypto.createDecipheriv('aes-256-cbc', @aes_key, nonceBuf)
    decrypted = aes.update(ciphertext, 'hex', 'utf8')
    decrypted += aes.final('utf8')