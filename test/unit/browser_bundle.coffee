
# This file bundles the test that you want to run in the browser

###################### HOW TO USE ######################
# 1) Require any files that you want to test in the browser.
# 2) Run 'gulp' at the root of the project
# 3) A test.html file will open up in your browser and run the tests

# PassphraseBox has a browser version because it can't use
# node-sodium, instead it uses libsodium.js and therefor
# had to be rewritten
PassphraseBoxTest = require('./passphrase_box_browser')
# MultiWallet = require('./multiwallet')