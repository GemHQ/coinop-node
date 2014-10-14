crypto = require "crypto"
{Const, SecretBox, Key, Random} = require("sodium")

salt = new Buffer(16)
Random.buffer(salt)
console.log salt.toString("hex")
password = "sunshine"
iterations = 100000

key = crypto.pbkdf2Sync(password, salt, iterations, 32)
key = new Key.SecretBox(key)
box = new SecretBox(key)

result = box.encrypt("monkeyshines", "ascii")
console.log Object.keys(result)


