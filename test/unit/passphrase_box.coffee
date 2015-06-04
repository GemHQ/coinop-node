
{crypto: {PassphraseBox}} = require "../../src/index"
expect = require('chai').expect
{encryptionData} = require('../data/passphrase_box.json')

  
# describe 'encrypt', ->
#   it 'should return an object containing ciphertext, salt, noce, and iterations', (done) ->
#     PassphraseBox.encrypt 'passphrase', 'secret', (error, encryptedData) ->
#       console.log error, encryptedData
#       expect(encryptedData).to.include.keys('iterations', 'salt',
#                                             'nonce', 'ciphertext')
#       done(error)


describe 'decrypt', ->
  it 'should decrypt the plain text', (done) ->
    data = encryptionData[0]
    PassphraseBox.decrypt(data.passphrase, data, (error, plain) ->
      expect(plaintext).to.equal(data.plaintext)
      done(error)
    )

# describe 'decrypt', ->
#   it 'should decrypt the plain text', (done) ->
#     encryptionData.forEach (data) ->
#       plaintext = PassphraseBox.decrypt(data.passphrase, data)

#       expect(plaintext).to.equal(data.plaintext)


# describe 'full-circle encryption/decryption', ->
#   it 'should decreypt the encrypted', ->
#     encryptionData.forEach (data) ->
#       PassphraseBox.encrypt(data.passphrase, data.plaintext)
#       plaintext = PassphraseBox.decrypt(data.passphrase, data)

#       expect(plaintext).to.equal(data.plaintext)
