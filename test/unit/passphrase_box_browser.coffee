
PassphraseBox = require('../../src/crypto/passphrase_box')
expect = require('chai').expect
{encryptionData} = require('../data/passphrase_box.json')

describe 'PassphraseBox', ->
  @timeout(0)
  describe 'encrypt', ->
    it 'should return an object containing ciphertext, salt, noce, and iterations', (done) ->
      PassphraseBox.encrypt 'passphrase', 'secret', (error, encryptedData) ->
        expect(encryptedData).to.include.keys('iterations', 'salt',
                                              'nonce', 'ciphertext')
        done(error)


describe 'decrypt', ->
  @timeout(0)
  it 'should decrypt the plain text', (done) ->
    data = encryptionData[0]
    PassphraseBox.decrypt data.passphrase, data, (error, plaintext) ->
      expect(plaintext).to.equal(data.plaintext)
      done(error)


  describe 'full-circle encryption/decryption', ->
    @timeout(0)
    it 'should decrypt the encrypted', (done) ->
      data = encryptionData[0]
      PassphraseBox.encrypt data.passphrase, data.plaintext, (error, encryptedData) ->
        PassphraseBox.decrypt data.passphrase, encryptedData, (error, plaintext) ->
          expect(plaintext).to.equal(data.plaintext)
          done(error)
