PassphraseBox = require "../../src/crypto/passphrase_box"
expect = require('chai').expect
{aesData} = require('../data/hybrid_box.json')

describe 'encrypt', ->
  it 'should create the correct ciphertext using aes', (done) ->
    testAll = (aesData, i, error) ->
      len = aesData.length
      if i == len or error?
        return done(error)
      else
        data = aesData[i]
        new PassphraseBox(data, (error, box) ->
          testAll(aesData, i+1, error) if error
          encrypted = box.encrypt(data.plaintext, data.iv)
          expect(encrypted.ciphertext).to.equal(data.ciphertext)
          testAll(aesData, i+1, error)
        )
    testAll(aesData, 0, null)


describe 'encrypt keys', ->
  it 'should return an object containing ciphertext, salt, iv, and iterations', (done) ->
    data = aesData[1]
    PassphraseBox.encrypt data.passphrase, data.plaintext, (error, encryptedData) ->
      expect(encryptedData).to.include.keys('iterations', 'salt',
                                            'iv', 'ciphertext')
      done(error)


describe 'full-circle encryption/decryption', ->
  @timeout(3000)
  it 'should decreypt the encrypted', (done) ->
    testAll = (aesData, i, error) ->
      len = aesData.length
      if i == len or error?
        return done(error)
      else
        data = aesData[i]
        PassphraseBox.encrypt(data.passphrase, data.plaintext, (error, encrypted) ->
          testAll(aesData, i+1, error) if error
          PassphraseBox.decrypt(data.passphrase, encrypted, (error, plaintext) ->
            expect(plaintext).to.equal(data.plaintext)
            testAll(aesData, i+1, error)
          )
        )
    testAll(aesData, 0, null)
