crypto = require "crypto"

module.exports = class PassphraseBoxAES

  ITERATIONS = 90000
  ITERATIONS_RANGE = 20000

  @encrypt: (passphrase, plaintext, callback) ->
    new @({passphrase}, (error, box) ->
      callback(error, box.encrypt(plaintext))
    )


  @decrypt: (passphrase, encrypted, callback) ->
    {salt, iterations, iv, ciphertext} = encrypted
    new @({passphrase, salt, iterations}, (error, box) ->
      callback(error, box.decrypt(ciphertext, iv))
    )


  constructor: ({passphrase, salt, @iterations}, callback) ->
    if salt
      @salt = new Buffer(salt, "hex")
    else
      try
        @salt = crypto.randomBytes(16)
      catch
        throw new Error("Error generating random bytes")

    unless @iterations
      array = new UintArray32(1)
      crypto.getRandomValues(array)
      @iterations = ITERATIONS + (array[0] % ITERATIONS_RANGE)

    crypto.pbkdf2(passphrase, @salt, @iterations, 64, (error, buffer) =>
      return callback(error) if error


      @aes_key = buffer.slice(0,32)
      @hmac_key = buffer.slice(32,64)
      callback(null, @)
    )


  encrypt: (plaintext, iv) ->
    try
      iv ?= crypto.randomBytes(16)
    catch
      throw new Error("Error generating random bytes")

    aes = crypto.createCipheriv('aes-256-cbc', @aes_key, iv)
    encrypted = aes.update(plaintext, 'utf8')
    encrypted = Buffer.concat([encrypted, aes.final()])

    mac = crypto.createHmac('sha256', @hmac_key)
      .update(Buffer.concat([iv, encrypted]))
      .digest()

    ciphertext = Buffer.concat([encrypted, mac])

    {
      iterations: @iterations
      salt: @salt.toString("hex")
      iv: iv.toString("hex")
      ciphertext: ciphertext.toString("hex")
    }


  decrypt: (cipherData, iv) ->
    cipherDataBuf = new Buffer(cipherData, 'hex')
    ivBuf = new Buffer(iv, 'hex')
    ciphertext = cipherDataBuf.slice(0, -32)
    hmacOld = cipherDataBuf.slice(-32).toString('hex')
    hmacNew = crypto.createHmac('sha256', @hmac_key)
      .update(Buffer.concat([ivBuf, ciphertext]))
      .digest()
      .toString('hex')

    if hmacOld != hmacNew
      throw new Error('Invalid authentication code - this
                       ciphertext may have been tampered with')

    aes = crypto.createDecipheriv('aes-256-cbc', @aes_key, Buf)
    decrypted = aes.update(ciphertext, 'hex', 'utf8')
    decrypted += aes.final('utf8')
