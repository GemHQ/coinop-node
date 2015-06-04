
{crypto: {PassphraseBox}} = require "../../src/index"
expect = require('chai').expect
{encryptionData} = require('../data/passphrase_box.json')

  
describe 'encrypt', ->
  it 'should return an object containing ciphertext, salt, noce, and iterations', (done) ->
    PassphraseBox.encrypt 'a phrase a day', 'keeps the boogy man away', (error, encryptedData) ->
      console.log error, encryptedData
      expect(encryptedData).to.include.keys('iterations', 'salt',
                                            'nonce', 'ciphertext')
      done(error)


describe 'decrypt', ->
  it 'should decrypt the plain text', (done) ->
    data = encryptionData[3]
    PassphraseBox.decrypt(data.passphrase, data, (error, plaintext) ->
      expect(plaintext).to.equal(data.plaintext)
      done(error)
    )

describe 'decrypt', ->
  it 'should decrypt the plain text', (done) ->
    
    decryptAll = (encryptionData, i, error) ->
      len = encryptionData.length
      if i == len or error? 
        done(error)
      else
        data = encryptionData[i]
        PassphraseBox.decrypt(data.passphrase, data, (error, plaintext) ->
          expect(plaintext).to.equal(data.plaintext)
          decryptAll(encryptionData, i+1, error)
        )
    decryptAll(encryptionData, 0, null)




describe 'full-circle encryption/decryption', ->
  it 'should decreypt the encrypted', (done) ->
    testAll = (encryptionData, i, error) ->
      len = encryptionData.length
      if i == len or error? 
        done(error)
      else
        data = encryptionData[i]
        PassphraseBox.encrypt(data.passphrase, data.plaintext, (error, encrypted) ->
          testAll(encryptionData, i+1, error) if error
          PassphraseBox.decrypt data.passphrase, encrypted, (error, plaintext) -> 
            expect(plaintext).to.equal(data.plaintext)
            testAll(encryptionData, i+1, error)
        )
    testAll(encryptionData, 0, null)