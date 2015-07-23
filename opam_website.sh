#!/bin/sh

export PATH=$PATH:/usr/local/bin

cd /home/clarus/www/opam-website/extraction
eval `opam config env --root=/home/clarus/.opam` make
eval `opam config env --root=/home/clarus/.opam` opam update
eval `opam config env --root=/home/clarus/.opam` ./opamWebsite.native
cp -R html ../../coq-io/output/opam
