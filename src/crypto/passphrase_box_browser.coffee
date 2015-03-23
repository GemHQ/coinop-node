crypto = require "./crypto"
sodium = require("libsodium-wrappers")

DIGEST = 'sha1'
ITERATIONS = 10000

encrypt = (passphrase, plaintext, callback) ->
  # Note: sodium.crypto_shorthash_KEYBYTES == 16
  salt = sodium.randombytes_buf(sodium.crypto_shorthash_KEYBYTES)

  # Note: sodium.crypto_secretbox_KEYBYTES == 32
  crypto.pbkdf2(passphrase, salt, ITERATIONS,
                sodium.crypto_secretbox_KEYBYTES, DIGEST,
                (error, key) ->
                  return callback(error) if error

                  # Note: sodium.crypto_secretbox_NONCEBYTES == 24
                  nonce = sodium.randombytes_buf(sodium.crypto_secretbox_NONCEBYTES)

                  ciphertext = sodium.crypto_secretbox_easy(plaintext, nonce, key, 'hex')

                  callback null, {
                    iterations: ITERATIONS,
                    salt: sodium.to_hex(salt),
                    nonce: sodium.to_hex(nonce),
                    ciphertext
                  }
  )

  

decrypt = (passphrase, encryptionData, callback) ->
  {salt, iterations, nonce, ciphertext} = encryptionData
  salt = sodium.from_hex(salt)
  nonce = sodium.from_hex(nonce)
  ciphertext = sodium.from_hex(ciphertext)

  # Note: sodium.crypto_secretbox_KEYBYTES == 32
  crypto.pbkdf2(passphrase, salt, iterations,
                sodium.crypto_secretbox_KEYBYTES, DIGEST,
                (error, key) ->
                  return callback(error) if error

                  plaintext = sodium.crypto_secretbox_open_easy(ciphertext, nonce, key, 'text')

                  callback(null, plaintext)
  )


module.exports = {

  encrypt,

  decrypt

}
