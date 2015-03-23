
{crypto: {PassphraseBox}} = require "../../src/index"
expect = require('chai').expect
{encryptionData} = require('../data/passphrase_box.json')

  
describe 'encrypt', ->
  it 'should return an object containing ciphertext, salt, noce, and iterations', ->
    encryptedData = PassphraseBox.encrypt('passphrase', 'secret')

    expect(encryptedData).to.include.keys('iterations', 'salt',
                                          'nonce', 'ciphertext')


describe 'decrypt', ->
  it 'should decrypt the plain text', ->
    encryptionData.forEach (data) ->
      plaintext = PassphraseBox.decrypt(data.passphrase, data)

      expect(plaintext).to.equal(data.plaintext)


describe 'full-circle encryption/decryption', ->
  it 'should decreypt the encrypted', ->
    encryptionData.forEach (data) ->
      PassphraseBox.encrypt(data.passphrase, data.plaintext)
      plaintext = PassphraseBox.decrypt(data.passphrase, data)

      expect(plaintext).to.equal(data.plaintext)
