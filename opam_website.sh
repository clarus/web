#!/bin/sh

set -e

export PATH=$PATH:/usr/local/bin

cd /home/clarus/www/opam-website/extraction
eval `opam config env` make
opam update
./opamWebsite.native
cp -RTfv html ../../coq-io/output/opam
