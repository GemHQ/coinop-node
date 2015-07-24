PassphraseBox = require('./passphrase_box')
AESBox = require('./aes_box')

module.exports = class HybridBox

  @encrypt: (passphrase, plaintext, callback) ->
    AESBox.encrypt(passphrase, plaintext, callback)


  @decrypt: (passphrase, encrypted, callback) ->
    {iv} = encrypted
    if iv?
      AESBox.decrypt(passphrase, encrypted, callback)
    else
      plaintext = PassphraseBox.decrypt(passphrase, encrypted)
      callback(null, plaintext)


  constructor: ({passphrase, salt, iterations}, callback) ->
    new AESBox({passphrase, salt, iterations}, callback)
