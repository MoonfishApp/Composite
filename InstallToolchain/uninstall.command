# Script to uninstall solium, truffle, and node.
# Use to restore computer to a state where only brew and Ganache is installed
# Do not add this script to any target.
#!/bin/sh

npm -g uninstall solium
npm -g uninstall truffle
npm -g uninstall ganache-cli
npm -g uninstall etherlime
npm -g uninstall tronbox
#brew uninstall node


opam remove ocaml-migrate-parsetree core cryptokit ppx_sexp_conv yojson batteries angstrom hex ppx_deriving menhir oUnit dune stdint fileutils ctypes ctypes-foreign bisect_ppx secp256k1 --yes
brew uninstall ocaml
brew uninstall gpatch opam

brew uninstall pkg-config
brew uninstall libffi
brew uninstall openssl
brew uninstall boost
brew uninstall gmp
