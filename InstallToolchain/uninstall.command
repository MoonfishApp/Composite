# Script to uninstall solium, truffle, and node.
# Use to restore computer to a state where only brew and Ganache is installed
# Do not add this script to any target.
#!/bin/sh

npm -g uninstall solium
npm -g uninstall truffle
npm -g uninstall etherlime
npm -g uninstall tronbox
#brew uninstall node

brew uninstall ocaml
brew uninstall gpatch
brew uninstall opam
brew uninstall pkg-config
brew uninstall libffi
brew uninstall openssl
brew uninstall boost
brew uninstall gmp
