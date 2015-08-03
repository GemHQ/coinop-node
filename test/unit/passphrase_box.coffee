HybridBox = require "../../src/crypto/hybrid_box"
AESBox = require "../../src/crypto/aes_box"
expect = require('chai').expect
{sodiumData} = require('../data/passphrase_box.json')
{aesData} = require('../data/hybrid_box.json')


describe 'encryp', -> 
  it 'should create the correct ciphertext using aes', (done) ->
    testAll = (aesData, i, error) ->
      len = aesData.length
      if i == len or error?
        return done(error)
      else
        data = aesData[i]
        new HybridBox(data, (error, box) ->
          testAll(aesData, i+1, error) if error
          encrypted = box.encrypt(data.plaintext, data.iv)
          expect(encrypted.ciphertext).to.equal(data.ciphertext)
          testAll(aesData, i+1, error)
        )
    testAll(aesData, 0, null)


describe 'encrypt keys', ->
  it 'should return an object containing ciphertext, salt, iv, and iterations', (done) ->
    data = aesData[1]
    HybridBox.encrypt data.passphrase, data.plaintext, (error, encryptedData) ->
      expect(encryptedData).to.include.keys('iterations', 'salt',
                                            'iv', 'ciphertext')
      done(error)


describe 'decrypt', ->
  it 'should decrypt the plain text using sodium', (done) ->
    decryptAll = (aesData, i, error) ->
      len = aesData.length
      if i == len or error? 
        done(error)
      else
        data = aesData[i]
        HybridBox.decrypt(data.passphrase, data, (error, plaintext) ->
          expect(plaintext).to.equal(data.plaintext)
          decryptAll(aesData, i+1, error)
        )
    decryptAll(aesData, 0, null)


describe 'full-circle encryption/decryption', ->
  it 'should decreypt the encrypted', (done) ->
    testAll = (aesData, i, error) ->
      len = aesData.length
      if i == len or error? 
        return done(error)
      else
        data = aesData[i]
        AESBox.encrypt(data.passphrase, data.plaintext, (error, encrypted) ->
          testAll(aesData, i+1, error) if error
          AESBox.decrypt(data.passphrase, encrypted, (error, plaintext) -> 
            expect(plaintext).to.equal(data.plaintext)
            testAll(aesData, i+1, error)
          )
        )
    testAll(aesData, 0, null)