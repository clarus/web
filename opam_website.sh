#!/bin/sh

export PATH=$PATH:/usr/local/bin

cd /home/clarus/www/opam-website/extraction
eval `opam config env` make
opam update
./opamWebsite.native
cp -R html ../../coq-io/output/opam
