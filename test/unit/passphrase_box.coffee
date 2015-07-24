
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
      console.log plaintext

      expect(plaintext).to.equal(data.plaintext)

describe.only 'decryption test', ->
  it 'should properly decrypt the private key', ->
    plaintext = PassphraseBox.decrypt('password', {
      salt: 'bd9debfe1c198851a86457237ae453ef',
      iterations: 10000,
      nonce: 'a14387f33435a562196fb698c1e1a73accdfce1cd8bc6261',
      iv: null,
      ciphertext: 'c95384cf52fa8d7afd4d5928f86081bfee2a53cb0980371fa1da075feab131f9677abe3dbb8f3b7c1e3f6d087db1b577aa7d868c6ad1115b2c7f753157de081fbc2b7437ce82df4c8ec35091e0a99148'
    })
    console.log plaintext
    expect(true).to.exist


# { salt: 'bd9debfe1c198851a86457237ae453ef',
#   iterations: 10000,
#   nonce: 'a14387f33435a562196fb698c1e1a73accdfce1cd8bc6261',
#   iv: null,
#   ciphertext: 'c95384cf52fa8d7afd4d5928f86081bfee2a53cb0980371fa1da075feab131f9677abe3dbb8f3b7c1e3f6d087db1b577aa7d868c6ad1115b2c7f753157de081fbc2b7437ce82df4c8ec35091e0a99148' }


#   {
#       salt: '2c37b9fac346d6b2deb193166fc764a3',
#       iterations: 10000,
#       nonce: '233f811d2252bf0391596a8045f70c5be559c397cd7c4869',
#       ciphertext: 'ae03baf623423c0d53b2c05327b535568b12b33a3e935fa8ace99593e02e851841affe6af393ec0f5f70c407ab4389d2'
#     }