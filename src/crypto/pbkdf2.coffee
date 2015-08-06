cryptoJS = require 'crypto'

browserNativePbkdf2 = ->
  try
    return false unless global.crypto
    return false if global.crypto.webkitSubtle

    buffer = new Buffer('data', 'binary')
    global.crypto?.subtle?.importKey 'raw', buffer, {name: 'PBKDF2'}, false, ['deriveBits']
    return true
  catch error
    console.error error
    return false

jsPBKDF2 = cryptoJS.pbkdf2

nativePBKDF2 = (passphrase, salt, iterations, keySize, callback) ->
  keyBuffer = new Buffer(passphrase, 'binary')
  global.crypto.subtle.importKey('raw', keyBuffer, {name: 'PBKDF2'}, false, ['deriveBits'])
    .then (key) ->
      global.crypto.subtle.deriveBits({
        name: 'PBKDF2',
        salt: salt,
        iterations: iterations,
        hash: {name: 'SHA-1'}
      }, key, 512)
        .then (key) ->
          callback(null, key)
        .catch (error) ->
          callback(error, null)
    .catch (error) ->
      callback(error, null)


module.exports = if browserNativePbkdf2() then nativePBKDF2 else jsPBKDF2


